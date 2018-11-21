//
//  Graph.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

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

struct Graph: ProviderProtocol {

    fileprivate let entries: [ContainerKey: AnyBinding]
    
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
        let key = ContainerKey(type: type)
        
        return entries[key]
    }
}

extension ComponentInfo {
    func buildGraph() -> Graph {
        var entries = [ContainerKey: AnyBinding]()
        
        for key in getAllKeys() {
            let allProviders = getAllProviderInfos(forType: key.type)
            let firstProvider = allProviders[0]
            
            let binding = firstProvider.binding.copy()
            
            if allProviders.count > 1 {
                // Assuming that the component has been validated
                for p in allProviders.suffix(from: 1) {
                    binding.bindingType.acceptBinding(p.binding.copy())
                }
            }
            
            entries[key] = binding
        }
        
        return Graph(entries: entries)
    }
}
