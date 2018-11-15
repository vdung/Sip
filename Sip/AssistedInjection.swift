//
//  AssistedInjection.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/14.
//

public protocol AssistedInjectionFactoryProtocol {
    associatedtype Argument
    associatedtype Element

    init(create: @escaping (Argument) -> Element)
}

public struct AssistedInjectionFactory<Argument, Element>: AssistedInjectionFactoryProtocol {
    public let create: (Argument) -> Element

    public init(create: @escaping (Argument) -> Element) {
        self.create = create
    }
}

public protocol AssistedInjectionProtocol {
    associatedtype Argument
}

public extension BinderDelegate {

    public func bind<T: AssistedInjectionProtocol>(factoryOf: T.Type) -> Binder<AssistedInjectionFactory<T.Argument, T>> {
        return bind(AssistedInjectionFactory<T.Argument, T>.self)
    }

    public func bind<Argument, T>(factoryOf: T.Type) -> Binder<AssistedInjectionFactory<Argument, T>> {
        return bind(AssistedInjectionFactory<Argument, T>.self)
    }
}
