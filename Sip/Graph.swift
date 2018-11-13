//
//  Graph.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

struct ContainerKey {
    let type: Any.Type
}

extension ContainerKey: Hashable {
    var hashValue: Int {
        return "\(type)".hashValue
    }
}

func ==(lhs: ContainerKey, rhs: ContainerKey) -> Bool {
    return lhs.type == rhs.type
}

func unwrapKey(_ rawType: Any.Type) -> ContainerKey {
    var keyType: Any.Type = rawType
    while let providerType = keyType as? AnyProvider.Type {
        keyType = providerType.element
    }
    
    return ContainerKey(type: keyType)
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

class Graph: Container {
    
    fileprivate var entries: [ContainerKey: AnyBinding]
    
    convenience init() {
        self.init(entries: [:])
    }
    
    fileprivate init(entries: [ContainerKey: AnyBinding]) {
        self.entries = entries
    }
    
    func provider<T>() -> T where T: AnyProvider {
        let key = unwrapKey(T.self)
        guard let binding = entries[key] else {
            preconditionFailure("Unsatisfied dependency: \(key.type)")
        }
        
        var provider = binding.createProvider(provider: self)
        
        provider = wrapProvider(provider, rawType: T.self)
        
        return provider.getAny() as! T
    }
    
    func register<B>(binding: B) where B : BindingBase, B.Element : ProviderBase {
        let key = ContainerKey(type: B.Element.Element.self)
        if let existingBinding = entries[key] {
            existingBinding.bindingType.acceptBinding(binding)
        } else {
            entries[ContainerKey(type: B.Element.Element.self)] = binding
        }
    }
    
    func createSubContainer() -> Graph {
        return Graph(entries: entries.mapValues { $0.copy() })
    }
    
    func validate<T>(_ type: T.Type, file: StaticString = #file, line: Int = #line, function: StaticString = #function) throws {
        let validator = Validator(entries: entries)
        try validator.validate(type, file: file, line: line, function: function)
    }
}
