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

class Graph: Container {

    fileprivate let parent: Container?
    fileprivate var entries: [ContainerKey: AnyBinding] = [:]

    convenience init() {
        self.init(parent: nil)
    }

    fileprivate init(parent: Container?) {
        self.parent = parent
    }
    
    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase {
        let type = unwrapType(B.Element.Element.self)
        if let existingBinding = getBinding(forType: type) {
            existingBinding.bindingType.acceptBinding(binding)
        } else {
            entries[ContainerKey(type: B.Element.Element.self)] = binding
        }
    }
    
    func provider<T>() -> T where T: AnyProvider {
        let type = unwrapType(T.self)
        guard let binding = getBinding(forType: type) else {
            preconditionFailure("Unsatisfied dependency: \(type)")
        }
        
        return T.wrap {
            binding.createProvider(provider: self)
        }
    }
    
    func getBinding(forType type: Any.Type) -> AnyBinding? {
        let key = ContainerKey(type: type)
        
        if let binding = entries[key] {
            return binding
        }
        
        if let binding = parent?.getBinding(forType: type) {
            entries[key] = binding.copy()
        }
        
        return entries[key]
    }

    func createSubContainer() -> Graph {
        return Graph(parent: self)
    }
}
