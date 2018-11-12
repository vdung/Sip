//
//  Binder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol BinderProtocol {
    associatedtype Element
    
    func to(binding: Binding<Provider<Element>>)
}

public class Binder<Element>: BinderProtocol {
    private let elementType: Element.Type
    private let bindFunc: (Binding<Provider<Element>>) -> Void
    
    init(elementType: Element.Type, bindFunc: @escaping (Binding<Provider<Element>>) -> Void) {
        self.elementType = elementType
        self.bindFunc = bindFunc
    }
    
    public func to(binding: Binding<Provider<Element>>) {
        bindFunc(binding)
    }
}

public extension Container {
    func bind<T>(_ type: T.Type) -> Binder<T> {
        return Binder(elementType: type, bindFunc: self.register)
    }
}
