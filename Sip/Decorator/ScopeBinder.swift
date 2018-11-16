//
//  ScopeBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

private class SharedBinding<UnderlyingBinding> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase {
    typealias Value = UnderlyingBinding.Element.Element
    typealias Element = ThrowingProvider<Value>

    private var value: Value?
    private let underlyingBinding: UnderlyingBinding

    var delegate: AnyBinding {
        return underlyingBinding
    }

    init(binding: UnderlyingBinding) {
        self.underlyingBinding = binding
    }

    func createElement(provider: ProviderProtocol) -> ThrowingProvider<Value> {
        return ThrowingProvider {
            if let value = self.value {
                return value
            }
            let p = self.underlyingBinding.createElement(provider: provider)
            self.value = try p.get()
            return self.value!
        }
    }

    func copy() -> AnyBinding {
        return self
    }
}

public class SharedInScopeBinder<B>: BinderDecorator where B: BinderProtocol {
    public typealias Element = B.Element
    typealias Wrapped = B

    private let binder: B

    required init(binder: B) {
        self.binder = binder
    }

    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        return binder.register(binding: SharedBinding(binding: binding))
    }
}

public extension BinderProtocol {
    func sharedInScope() -> SharedInScopeBinder<Self> {
        return decorate()
    }
}
