//
//  Graph.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

class Graph: ProviderProtocol {

    fileprivate let entries: [BindingKey: AnyBinding]
    fileprivate var providerCache: [BindingKey: AnyProvider] = [:]
    
    init(entries: [BindingKey: AnyBinding]) {
        self.entries = entries
    }
    
    func provider<T>() -> T where T: AnyProvider {
        let type = T.unwrap()
        let key = BindingKey(type: type)
        
        guard let binding = entries[key] else {
            preconditionFailure("Unsatisfied dependency: \(type)")
        }
        
        return T.wrap {
            if let provider = self.providerCache[key] {
                return provider
            }
            
            let provider = binding.createProvider(provider: self)
            self.providerCache[key] = provider
            return provider
        }
    }
}

extension ComponentInfo {
    
    func buildGraph() -> Graph {
        var entries = [BindingKey: AnyBinding]()
        
        for key in getAllKeys() {
            let allProviders = getAllProviderInfos(forType: key.type)
            let firstProvider = allProviders[0]
            
            var binding = firstProvider.binding.copy()
            
            if allProviders.count > 1 {
                // Assuming that the component has been validated
                for p in allProviders.suffix(from: 1) {
                    binding = binding.acceptBinding(p.binding.copy())
                }
            }
            
            entries[key] = binding
        }
        
        return Graph(entries: entries)
    }
}
