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
            
            guard type(of: value) == Element.self else {
                throw ProviderError.mismatchElement(type: Element.self, wrapped: value)
            }
            
            return value as! Element
        }
    }
    
    func wrap<T>() -> T where T: AnyProvider {
        var providerStack = [AnyProvider.Type]()
        var providerType: AnyProvider.Type = T.self
        
        while let elementType = providerType.element as? AnyProvider.Type {
            providerStack.append(elementType)
            providerType = elementType
        }
        
        var wrappedProvider: AnyProvider = self
        while let elementType = providerStack.popLast() {
            wrappedProvider = WrappingProvider(wrapped: elementType.init(wrapped: wrappedProvider))
        }
        
        return T(wrapped: wrappedProvider)
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
    
    private let provider: AnyProvider
    
    init(wrapped: AnyProvider) {
        self.provider = wrapped
    }
    
    func getAny() throws -> Any {
        return provider
    }
}
