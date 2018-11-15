//
//  AssistedInjection.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/14.
//

public struct AssistedInjectionFactory<Argument, Element> {
    public let create: (Argument) -> Element
    
    init(create: @escaping (Argument) -> Element) {
        self.create = create
    }
}

public protocol AssistedInjectionProtocol {
    associatedtype Argument
}

class AssistedInjection<Dependencies, Arguments, Element> {
    typealias FactoryFunc = (Dependencies, Arguments) -> Element
    let dependencies: Provider<Dependencies>
    let factory: FactoryFunc

    init(dependencies: Provider<Dependencies>, factory: @escaping FactoryFunc) {
        self.dependencies = dependencies
        self.factory = factory
    }

    func create(_ args: Arguments) -> Element {
        return factory(dependencies.get(), args)
    }
}

public extension BinderDelegate {
    
    public func bind<T: AssistedInjectionProtocol>(factoryOf: T.Type) -> Binder<AssistedInjectionFactory<T.Argument, T>> {
        return bind(AssistedInjectionFactory<T.Argument, T>.self)
    }
    
    public func bind<Argument, T>(factoryOf: T.Type) -> Binder<AssistedInjectionFactory<Argument, T>> {
        return bind(AssistedInjectionFactory<Argument, T>.self)
    }
}
