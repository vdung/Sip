//
//  ScopedBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/28.
//

import Foundation

private class ScopedProvider<Element>: ProviderBase {
    let getter: () throws -> Element
    let lock = NSLock()
    var element: Element?

    init(_ getter: @escaping () throws -> Element) {
        self.getter = getter
    }

    required convenience init(wrapped: AnyProvider) {
        self.init(wrapped.toGetter())
    }

    public func get() throws -> Element {
        // If we already have a value, we don't need to lock.
        if let element = self.element {
            return element
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        if let element = self.element {
            return element
        }
        
        let element = try getter()
        self.element = element
        return element
    }
}

private class ScopedBinding<UnderlyingBinding, Scoped> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, Scoped: Scope {
    typealias Value = UnderlyingBinding.Element.Element
    typealias Element = ScopedProvider<Value>

    private let underlyingBinding: UnderlyingBinding

    var delegate: AnyBinding {
        return underlyingBinding
    }

    var scope: Scope.Type {
        return Scoped.self
    }

    required convenience init(copy: ScopedBinding<UnderlyingBinding, Scoped>) {
        self.init(binding: UnderlyingBinding(copy: copy.underlyingBinding))
    }

    init(binding: UnderlyingBinding) {
        self.underlyingBinding = binding
    }

    func createElement(provider: ProviderProtocol) -> ScopedProvider<Value> {
        return ScopedProvider(wrapped: self.underlyingBinding.createElement(provider: provider))
    }
}

public class ScopedBinder<B, Scoped>: BinderDecorator where B: BinderProtocol, Scoped: Scope {
    public typealias Element = B.Element
    typealias Wrapped = B

    private let binder: B

    required init(binder: B) {
        self.binder = binder
    }

    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        return binder.register(binding: ScopedBinding<B, Scoped>(binding: binding))
    }
}

public extension BinderProtocol {
    func inScope<Scoped>(_: Scoped.Type) -> ScopedBinder<Self, Scoped> where Scoped: Scope {
        return decorate()
    }
}
