//
//  Provider.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

enum ProviderError: Error {
    case mismatchElement(type: Any.Type, wrapped: Any)
    case emptyProvider(type: Any.Type)
}

public protocol AnyProvider {
    static var element: Any.Type { get }

    init(wrapped: AnyProvider)
    func getAny() throws -> Any
}

extension AnyProvider {
    func toGetter<Element>() -> (() throws -> Element) {
        return {
            let value = try self.getAny()
            if let wrapped = value as? AnyProvider {
                guard let providerType = Element.self as? AnyProvider.Type else {
                    throw ProviderError.mismatchElement(type: Element.self, wrapped: value)
                }

                return providerType.init(wrapped: wrapped) as! Element
            }

            return value as! Element
        }
    }

    static func wrap(providerFactory: @escaping () -> AnyProvider) -> Self {
        guard let providerType = Self.element as? AnyProvider.Type else {
            return Self(wrapped: providerFactory())
        }

        // Self is provider's provider
        if providerType.element is AnyProvider.Type {
            return Self(wrapped: providerType.wrap(providerFactory: providerFactory))
        }

        return Self(wrapped: WrappingProvider(factory: providerFactory))
    }

    static func unwrap() -> Any.Type {
        var type: AnyProvider.Type = self
        while let elementType = type.element as? AnyProvider.Type {
            type = elementType
        }

        return type.element
    }

    func unwrap() throws -> AnyProvider {
        var unwrappedProvider: AnyProvider = self
        while let _ = type(of: unwrappedProvider).element as? AnyProvider.Type,
            let p = try unwrappedProvider.getAny() as? AnyProvider {
            unwrappedProvider = p
        }

        return unwrappedProvider
    }
}

public protocol ProviderBase: AnyProvider {
    associatedtype Element

    func get() throws -> Element
}

extension ProviderBase {
    public static var element: Any.Type {
        return Element.self
    }

    public func getAny() throws -> Any {
        return try get()
    }
}

public struct Provider<Element>: ProviderBase {
    let getter: () throws -> Element

    public init(_ getter: @escaping () throws -> Element) {
        self.getter = getter
    }

    public init(wrapped: AnyProvider) {
        self.init(wrapped.toGetter())
    }

    public func get() -> Element {
        return try! getter()
    }
}

public struct ThrowingProvider<Element>: ProviderBase {
    let getter: () throws -> Element

    public init(_ getter: @escaping () throws -> Element) {
        self.getter = getter
    }

    public init(wrapped: AnyProvider) {
        self.init(wrapped.toGetter())
    }

    public func get() throws -> Element {
        return try getter()
    }
}

struct WrappingProvider: AnyProvider {
    static var element: Any.Type {
        return AnyProvider.self
    }

    private let providerFactory: () -> AnyProvider

    init(wrapped: AnyProvider) {
        self.init { wrapped }
    }

    init(factory: @escaping () -> AnyProvider) {
        self.providerFactory = factory
    }

    func getAny() throws -> Any {
        return providerFactory()
    }
}
