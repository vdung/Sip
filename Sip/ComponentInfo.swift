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

private class DependenciesInfo: ProviderProtocol {
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

private struct ResolveInfo {
    let providerType: AnyProvider.Type
    let provider: ProviderInfo
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
    
    fileprivate func finalize(bindingStack: [ResolveInfo], errors: inout [ValidationError]) {
        for d in dependencies {
            component.finalize(resolvedType: d, bindingStack: bindingStack, errors: &errors)
        }
    }
}

class ComponentInfo: ComponentBuilderProtocol, BinderDelegate {
    weak var parent: ComponentInfo?

    let rootType: AnyProvider.Type
    let seedType: Any.Type
    var providers: [BindingKey: [ProviderInfo]] = [:]
    var parentDependencies = Set<BindingKey>()

    init<C>(parent: ComponentInfo?, componentType: C.Type) where C: Component {
        self.parent = parent
        self.rootType = Provider<C.Root>.self
        self.seedType = C.Seed.self

        C.configure(builder: self)
        C.configureRoot(binder: bind(C.Root.self))
    }

    private func addProvider(_ providerInfo: ProviderInfo, forType type: Any.Type) {
        let key = BindingKey(type: type)
        var existing = providers[key, default: []]
        existing.append(providerInfo)
        providers[key] = existing
    }
    
    fileprivate func finalize(bindingStack: [ResolveInfo], errors: inout [ValidationError]) {
        var providerInfos = self.providers
        
        var component = self
        while let parent = component.parent {
            let parentProviders = parent.providers
                .mapValues { providerInfos in
                    providerInfos
                        .filter {
                            // We only copy unscoped bindings from ancestors.
                            // For scoped bindings, get the provider directly.
                            $0.binding.scope == Unscoped.self && $0.component === parent
                        }
                        .map {
                            ProviderInfo(component: self, binding: $0.binding)
                    }
                }
                .filter { $0.value.count > 0 }
            
            providerInfos.merge(parentProviders) { $1 + $0 }
            component = parent
        }
        self.providers = providerInfos
        
        finalize(resolvedType: rootType, bindingStack: bindingStack, errors: &errors)
    }
    
    fileprivate func finalize(resolvedType: AnyProvider.Type, bindingStack: [ResolveInfo], errors: inout [ValidationError]) {
        let rawType = resolvedType.unwrap()
        let key = BindingKey(type: rawType)
        
        guard let providerInfos = self.providers[key] else {
            if ancestorHasBinding(forKey: key) {
                parentDependencies.insert(key)
            } else if rawType != seedType {
                errors.append(
                    ValidationError.unsatisfiedDependency(rawType, requiredBy: bindingStack.map { $0.provider.binding })
                )
            }
            
            return
        }
        if let index = bindingStack.lastIndex(where: {
            $0.providerType.unwrap() == rawType
        }) {
            if bindingStack.suffix(from: index)
                .filter({
                    // Check whether there is any seam in the binding chain.
                    // A seam can either be a Provider<T> or a component builder binding
                    $0.providerType.element != $0.providerType.unwrap()
                        || $0.provider.component !== self
                })
                .count == 0 {
                
                let cycle = bindingStack
                    .suffix(from: index)
                    .map { $0.provider.binding }
                    + [providerInfos[0].binding]
                
                errors.append(
                    ValidationError.cyclicDependency(cycle: cycle)
                )
            }
            
            return
        }
        
        let multiBindingCount = providerInfos
            .filter { $0.binding.isMultiBinding() }
            .count
        
        if providerInfos.count > 1 && providerInfos.count > multiBindingCount {
            errors.append(
                ValidationError.boundMultipleTimes(
                    resolvedType,
                    bindings: providerInfos.map { $0.binding }
                )
            )
        }
        
        for p in providerInfos {
            let newStack = bindingStack.appending(ResolveInfo(providerType: resolvedType, provider: p))
            if p.component !== self {
                p.component.finalize(bindingStack: newStack, errors: &errors)
            } else {
                p.finalize(
                    bindingStack: newStack,
                    errors: &errors
                )
            }
        }
        
        self.providers[key] = providerInfos
    }
    
    func ancestorHasBinding(forKey key: BindingKey) -> Bool {
        var component = self
        while let parent = component.parent {
            if parent.providers.keys.contains(key) {
                return true
            }
            component = parent
        }
        
        return false
    }
    
    func finalize() throws {
        var errors = [ValidationError]()
        finalize(bindingStack: [], errors: &errors)
        
        if errors.count == 1 {
            throw errors[0]
        }
        if errors.count > 1 {
            throw ValidationError.multipleErrors(errors)
        }
    }

    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase {
        addProvider(ProviderInfo(component: self, binding: binding), forType: B.Element.unwrap())
    }

    func subcomponent<C>(_ componentType: C.Type) where C: Component {
        let child = ComponentInfo(parent: self, componentType: componentType)
        let provider = C.Builder.providerInfo(componentInfo: child)
        addProvider(provider, forType: C.Builder.self)
    }
}

extension ComponentBuilder {
    
    static func providerInfo(file: StaticString=#file, line: Int=#line, function: StaticString=#function, componentInfo: ComponentInfo) -> ProviderInfo {
        let binding = Binding(file: file, line: line, function: function, bindingType: .unique, scope: Unscoped.self) { parent -> Provider<ComponentElement.Builder> in
            
            let graphBuilder = Graph.Builder<ComponentElement>(componentInfo: componentInfo, parent: parent)
            
            return Provider {
                self.init(builder: graphBuilder)
            }
        }
        
        let provider = ProviderInfo(component: componentInfo, binding: binding)
        return provider
    }
}

private extension Array {
    func appending(_ element: Element) -> Array {
        var newArray = self
        newArray.append(element)
        return newArray
    }
}
