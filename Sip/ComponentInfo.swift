//
//  ComponentInfo.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/20.
//

struct BindingKey {
    let type: Any.Type
}

extension BindingKey: Hashable {
    var hashValue: Int {
        return "\(type)".hashValue
    }
}

func ==(lhs: BindingKey, rhs: BindingKey) -> Bool {
    return lhs.type == rhs.type
}

class DependenciesInfo: ProviderProtocol {
    var dependencies: [AnyProvider.Type] = []

    init() {}

    func provider<T>() -> T where T: AnyProvider {
        self.dependencies.append(T.self)
        return T.wrap {
            Provider {
                preconditionFailure("Not implemented")
            }
        }
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
    weak var parent: ComponentInfo?
    
    let rootType: AnyProvider.Type
    var providers: [BindingKey: [ProviderInfo]] = [:]
    var parentDependencies = Set<BindingKey>()

    init<C>(parent: ComponentInfo?, componentType: C.Type) where C: Component {
        self.parent = parent
        self.rootType = Provider<C.Root>.self

        C.configure(builder: self)
        C.configureRoot(binder: bind(C.Root.self))
    }

    private func addProvider(_ providerInfo: ProviderInfo, forType type: Any.Type) {
        let key = BindingKey(type: type)
        var existing = providers[key, default: []]
        existing.append(providerInfo)
        providers[key] = existing
    }

    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase {
        addProvider(ProviderInfo(component: self, binding: binding), forType: B.Element.unwrap())
    }

    func subcomponent<C>(_ componentType: C.Type) where C: Component {
        let child = ComponentInfo(parent: self, componentType: componentType)
        let provider = C.Builder.provider(componentInfo: child)
        addProvider(provider, forType: C.Builder.self)
    }
}
