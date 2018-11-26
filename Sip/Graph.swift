//
//  Graph.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

struct Graph: ProviderProtocol {

    fileprivate let entries: [BindingKey: AnyBinding]
    
    func provider<T>() -> T where T: AnyProvider {
        let type = T.unwrap()
        guard let binding = getBinding(forType: type) else {
            preconditionFailure("Unsatisfied dependency: \(type)")
        }
        
        return T.wrap {
            binding.createProvider(provider: self)
        }
    }
    
    func getBinding(forType type: Any.Type) -> AnyBinding? {
        let key = BindingKey(type: type)
        
        return entries[key]
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
