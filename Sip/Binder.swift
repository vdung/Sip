//
//  Binder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol BinderProtocol {
    associatedtype Element
    
    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element
}

public protocol BinderDelegate {
    
    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase
}

public struct BinderReceipt: DelegatedBinding, CustomStringConvertible {
    let binding: AnyBinding
    
    var delegate: AnyBinding {
        return binding
    }
    
    public var description: String {
        return binding.description
    }
}

public extension BinderReceipt {
    public func debug() {
        print(self)
    }
}

public class Binder<Element>: BinderProtocol {
    private let elementType: Element.Type
    private let delegate: BinderDelegate
    
    public required convenience init(_ other: Binder<Element>) {
        self.init(elementType: other.elementType, delegate: other.delegate)
    }
    
    init(elementType: Element.Type, delegate: BinderDelegate) {
        self.elementType = elementType
        self.delegate = delegate
    }
    
    public func register<B>(binding: B) where B : BindingBase, B.Element : ProviderBase, B.Element.Element == Element {
        return delegate.register(binding: binding)
    }
}

public extension BinderDelegate {
    func bind<T>(_ type: T.Type) -> Binder<T> {
        return Binder(elementType: type, delegate: self)
    }
}

public extension BinderProtocol {
    
    internal func to(file: StaticString=#file, line: Int=#line, function: StaticString=#function, bindingType: BindingType = .unique, creator: @escaping CreatorFunc<Provider<Element>>) -> Void {
        return register(binding: Binding(file: file, line: line, function: function, bindingType: bindingType, create: creator))
    }
    
    public func to(file: StaticString=#file, line: Int=#line, function: StaticString=#function, value: Element) -> Void {
        return to(file: file, line: line, function: function) {
            _ in Provider { value }
        }
    }
    
    public func to(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping () -> Element) -> Void {
        return to(file: file, line: line, function: function) { _ in
            return Provider {
                factory()
            }
        }
    }
}
