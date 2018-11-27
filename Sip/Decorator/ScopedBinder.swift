//
//  ScopedBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/28.
//

private class ScopedProvider<Element>: ProviderBase {
    let getter: () throws -> Element
    var element: Element?
    
    init(_ getter: @escaping () throws -> Element) {
        self.getter = getter
    }
    
    required convenience init(wrapped: AnyProvider) {
        self.init(wrapped.toGetter())
    }
    
    public func get() throws -> Element {
        if let element = self.element {
            return element
        }
        let element = try getter()
        self.element = element
        return element
    }
}

private class ScopedBinding<UnderlyingBinding> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase {
    typealias Value = UnderlyingBinding.Element.Element
    typealias Element = ScopedProvider<Value>
    
    private let underlyingBinding: UnderlyingBinding
    
    var delegate: AnyBinding {
        return underlyingBinding
    }
    
    required convenience init(copy: ScopedBinding<UnderlyingBinding>) {
        self.init(binding: UnderlyingBinding(copy: copy.underlyingBinding))
    }
    
    init(binding: UnderlyingBinding) {
        self.underlyingBinding = binding
    }
    
    func createElement(provider: ProviderProtocol) -> ScopedProvider<Value> {
        return ScopedProvider(wrapped: self.underlyingBinding.createElement(provider: provider))
    }
}

public class ScopedBinder<B>: BinderDecorator where B: BinderProtocol {
    public typealias Element = B.Element
    typealias Wrapped = B
    
    private let binder: B
    
    required init(binder: B) {
        self.binder = binder
    }
    
    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        return binder.register(binding: ScopedBinding(binding: binding))
    }
}

public extension BinderProtocol {
    func sharedInScope() -> ScopedBinder<Self> {
        return decorate()
    }
}
