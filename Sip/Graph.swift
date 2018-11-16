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

    fileprivate var entries: [ContainerKey: AnyBinding]

    convenience init() {
        self.init(entries: [:])
    }

    fileprivate init(entries: [ContainerKey: AnyBinding]) {
        self.entries = entries
    }
    
    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase {
        let type = unwrapType(B.Element.Element.self)
        if let existingBinding = getBinding(forType: type) {
            existingBinding.bindingType.acceptBinding(binding)
        } else {
            entries[ContainerKey(type: B.Element.Element.self)] = binding
        }
    }
    
    func getBinding(forType type: Any.Type) -> AnyBinding? {
        let key = ContainerKey(type: type)
        return entries[key]
    }

    func createSubContainer() -> Graph {
        return Graph(entries: entries.mapValues { $0.copy() })
    }
}
