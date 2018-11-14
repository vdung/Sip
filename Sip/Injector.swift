//
//  Injector.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol InjectorProtocol {
    associatedtype Element
    init(_ injector: @escaping (Element) -> Void)
}

public struct Injector<Element>: InjectorProtocol {
    let injector: (Element) -> Void

    public init(_ injector: @escaping (Element) -> Void) {
        self.injector = injector
    }

    public func inject(_ instance: Element) {
        injector(instance)
    }
}

public extension BinderDelegate {
    public func bind<T>(injectorOf type: T.Type) -> Binder<Injector<T>> {
        return bind(Injector<T>.self)
    }
}
