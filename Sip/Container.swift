//
//  Container.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//


protocol Container: class, ProviderProtocol, BinderDelegate {
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
}
