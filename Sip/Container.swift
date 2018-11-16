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
    
    func provider<T>() -> T where T: AnyProvider {
        let type = unwrapType(T.self)
        guard let binding = getBinding(forType: type) else {
            preconditionFailure("Unsatisfied dependency: \(type)")
        }
        
        let provider = binding.createProvider(provider: self)
        
        return provider.wrap()
    }
}
