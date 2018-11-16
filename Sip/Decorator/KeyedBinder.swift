//
//  KeyedBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

private class KeyedBinding<UnderlyingBinding, Key> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase {

    typealias Value = UnderlyingBinding.Element.Element
    typealias Element = ThrowingProvider<(key: Key, value: Value)>

    private let underlyingBinding: UnderlyingBinding
    private let key: Key

    var delegate: AnyBinding {
        return underlyingBinding
    }

    init(binding: UnderlyingBinding, key: Key) {
        self.underlyingBinding = binding
        self.key = key
    }

    func copy() -> AnyBinding {
        return KeyedBinding(binding: underlyingBinding, key: key)
    }

    func createElement(provider: ProviderProtocol) -> ThrowingProvider<(key: Key, value: UnderlyingBinding.Element.Element)> {
        let p = underlyingBinding.createElement(provider: provider)
        let key = self.key
        return ThrowingProvider {
            (key, try p.get())
        }
    }
}

public class KeyedBinder<B, Key, Value>: BinderProtocol where B: BinderProtocol, B.Element == (key: Key, value: Value) {
    typealias Wrapped = B
    public typealias Element = Value

    private let binder: B
    private let key: Key

    init(binder: B, key: Key) {
        self.binder = binder
        self.key = key
    }

    public func register<B>(binding: B) where B: BindingBase, B.Element.Element == Element, B.Element: ProviderBase {
        return binder.register(binding: KeyedBinding(binding: binding, key: self.key))
    }
}

extension BinderProtocol {

    public func mapKey<Key, Value>(_ key: Key) -> KeyedBinder<Self, Key, Value> where Element == (key: Key, value: Value) {
        return KeyedBinder(binder: self, key: key)
    }
}
