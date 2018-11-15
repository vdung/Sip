//
//  Container.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//


protocol Container: ProviderProtocol, BinderDelegate {
    func getBinding(forType type: Any.Type) -> AnyBinding?
}

extension Container {
    
    func unwrapType(_ rawType: Any.Type) -> Any.Type {
        var type: Any.Type = rawType
        while let providerType = type as? AnyProvider.Type {
            type = providerType.element
        }
        
        return type
    }
    
    func wrapProvider(_ provider: AnyProvider, rawType: Any.Type) -> AnyProvider {
        var wrappedProvider = provider
        var keyType: Any.Type = rawType
        
        while let providerType = keyType as? AnyProvider.Type {
            keyType = providerType.element
            wrappedProvider = wrappedProvider.providerOf()
        }
        
        let providerElement = type(of: provider).element
        precondition(keyType == providerElement, "Mismatch provider element and rawType: \(providerElement) != \(keyType), original provider: \(type(of: provider))")
        
        return wrappedProvider
    }
    
    func provider<T>() -> T where T: AnyProvider {
        let type = unwrapType(T.self)
        guard let binding = getBinding(forType: type) else {
            preconditionFailure("Unsatisfied dependency: \(type)")
        }
        
        var provider = binding.createProvider(provider: self)
        
        provider = wrapProvider(provider, rawType: T.self)
        
        return provider.getAny() as! T
    }
}
