//
//  ComponentInfo.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/20.
//

class DependenciesInfo: ProviderProtocol {
    var dependencies: [AnyProvider.Type] = []
    
    init() {}
    
    func provider<T>() -> T where T : AnyProvider {
        self.dependencies.append(T.self)
        return T(wrapped: Provider {
            preconditionFailure("Not implemented")
        })
    }
}

struct ResolveInfo {
    let providerType: AnyProvider.Type
    let binding: AnyBinding
}

class ProviderInfo {
    unowned let component: ComponentInfo
    let binding: AnyBinding
    
    init(component: ComponentInfo, binding: AnyBinding) {
        self.component = component
        self.binding = binding
    }
    
    lazy var dependencies: [AnyProvider.Type] = { [unowned self] in
        let dependenciesInfo = DependenciesInfo()
        _ = self.binding.createProvider(provider: dependenciesInfo)
        return dependenciesInfo.dependencies
    }()
}

class ComponentInfo: ComponentBuilderProtocol, BinderDelegate {
    var parent: ComponentInfo?
    let rootType: AnyProvider.Type
    let componentType: Any.Type
    var providers: [ContainerKey: [ProviderInfo]] = [:]
    
    init<C>(parent: ComponentInfo?, componentType: C.Type) where C: Component {
        self.parent = parent
        self.rootType = Provider<C.Root>.self
        self.componentType = componentType
        
        componentType.configure(builder: self)
        componentType.configureRoot(binder: bind(C.Root.self))
    }
    
    private func addProvider(_ providerInfo: ProviderInfo, forType type: Any.Type) {
        let key = ContainerKey(type: type)
        var existing = providers[key, default: []]
        existing.append(providerInfo)
        providers[key] = existing
    }
    
    func register<B>(binding: B) where B : BindingBase, B.Element : ProviderBase {
        addProvider(ProviderInfo(component: self, binding: binding), forType: B.Element.unwrap())
    }
    
    func subcomponent<C>(_ componentType: C.Type) where C : Component {
        let child = ComponentInfo(parent: self, componentType: componentType)
        let provider = ComponentBuilder<C>.provider(componentInfo: child)
        addProvider(provider, forType: ComponentBuilder<C>.self)
    }
}

extension ComponentInfo {
    
    func getAllKeys() -> [ContainerKey] {
        var keys = Array(providers.keys)
        
        if let parent = self.parent {
            keys.insert(contentsOf: parent.getAllKeys(), at: 0)
        }
        
        return keys
    }
    
    func getAllProviderInfos(forType rawType: Any.Type) -> [ProviderInfo] {
        var providerInfos = providers[ContainerKey(type: rawType), default: []]
        
        if let parent = self.parent {
            providerInfos.insert(contentsOf: parent.getAllProviderInfos(forType: rawType), at: 0)
        }
        
        return providerInfos
    }
}
