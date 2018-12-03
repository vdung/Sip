//
//  Binder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol BinderProtocol {
    associatedtype Element

    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element
}

public protocol BinderDelegate {

    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase
}

public class Binder<Element>: BinderProtocol {
    private let elementType: Element.Type
    private let delegate: BinderDelegate

    init(elementType: Element.Type, delegate: BinderDelegate) {
        self.elementType = elementType
        self.delegate = delegate
    }

    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        return delegate.register(binding: binding)
    }
}

public extension BinderDelegate {
    func bind<T>(_ type: T.Type) -> Binder<T> {
        return Binder(elementType: type, delegate: self)
    }
}

public extension BinderProtocol {

    internal func to<P>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, bindingType: BindingType = .unique, creator: @escaping CreatorFunc<P>) where P: ProviderBase, P.Element == Element {
        register(binding: Binding(file: file, line: line, function: function, bindingType: bindingType, scope: Unscoped.self, create: creator))
    }

    public func to(file: StaticString=#file, line: Int=#line, function: StaticString=#function, value: Element) {
        to(file: file, line: line, function: function) {
            _ in Provider { value }
        }
    }

    public func to(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping () throws -> Element) {
        to(file: file, line: line, function: function) { _ in
            return ThrowingProvider {
                try factory()
            }
        }
    }
}
