//
//  Provider.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol AnyProvider {
    static var element: Any.Type { get }

    mutating func getAny() -> Any
}

extension AnyProvider {
    public init() {
        preconditionFailure("Empty provider for \(Self.element)")
    }
}

public protocol ProviderBase: AnyProvider {
    associatedtype Element

    func get() -> Element
}

extension ProviderBase {
    public static var element: Any.Type {
        return Element.self
    }

    public func getAny() -> Any {
        return get()
    }
}

public struct Provider<Element>: ProviderBase {
    let getter: () -> Element
    public func get() -> Element {
        return getter()
    }
}

extension AnyProvider {
    public func providerOf() -> AnyProvider {
        return Provider<Self> {
            return self
        }
    }
}

extension ProviderBase {
    func to<U>(converter: @escaping (Element) -> U) -> Provider<U> {
        return Provider<U> {
            converter(self.get())
        }
    }
}
