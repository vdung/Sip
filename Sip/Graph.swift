//
//  Graph.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

private class PlaceholderProvider: AnyProvider {
    static var element: Any.Type {
        return Any.self
    }

    let createProvider: () -> AnyProvider
    var provider: AnyProvider!
    fileprivate var finalized = false

    required convenience init(wrapped: AnyProvider) {
        self.init { wrapped }
    }

    init(createProvider: @escaping () -> AnyProvider) {
        self.createProvider = createProvider
    }

    func getAny() throws -> Any {
        finalize()
        return try provider.getAny()
    }

    func finalize() {
        guard !finalized else { return }
        defer {
            finalized = true
        }

        self.provider = createProvider()
    }
}

class Graph: ProviderProtocol {

    fileprivate let component: ComponentInfo
    fileprivate let parent: ProviderProtocol?
    fileprivate var providerCache: [BindingKey: PlaceholderProvider] = [:]

    init(component: ComponentInfo, seedProvider: AnyProvider, parent: ProviderProtocol?) {
        self.component = component
        self.parent = parent
        self.providerCache[BindingKey(type: component.seedType)] = PlaceholderProvider {
            seedProvider
        }
    }

    func provider<T>() -> T where T: AnyProvider {
        let rawType = T.unwrap()
        let key = BindingKey(type: rawType)

        if let provider = self.providerCache[key] {
            return T.wrap { provider }
        }

        let provider = PlaceholderProvider { [unowned self] in
            self.buildProvider(forType: T.self)
        }
        self.providerCache[key] = provider

        return T.wrap { provider }
    }

    private func buildProvider<T>(forType providerType: T.Type) -> AnyProvider where T: AnyProvider {
        let rawType = providerType.unwrap()
        if rawType == component.seedType {
            return PlaceholderProvider {
                Provider {
                    preconditionFailure("Seed is not initialized")
                }
            }
        }

        let key = BindingKey(type: rawType)

        guard let providerInfos = component.providers[key] else {
            guard let parent = parent else {
                preconditionFailure("Unsatisfied dependency: \(rawType)")
            }

            let parentProvider: T = parent.provider()
            return try! parentProvider.unwrap()
        }

        let firstProvider = providerInfos[0]

        var binding = firstProvider.binding

        if providerInfos.count > 1 {
            // Assuming that the component has been validated
            for p in providerInfos.suffix(from: 1) {
                binding = binding.acceptProvider(p.binding.createProvider(provider: self))
            }
        }

        return binding.createProvider(provider: self)
    }

    fileprivate func finalize() {
        repeat {
            for p in providerCache.values {
                p.finalize()
            }
        } while (providerCache.values.contains { !$0.finalized })
    }

    class Builder<C>: ProviderProtocol where C: Component {

        private let componentInfo: ComponentInfo
        private var parent: ProviderProtocol?
        private var ancestorProviders: [BindingKey: AnyProvider] = [:]

        init(componentInfo: ComponentInfo, parent: ProviderProtocol?) {
            self.componentInfo = componentInfo
            self.parent = parent
            defer {
                self.parent = nil
            }

            let graph = Graph(component: componentInfo, seedProvider: Provider<C.Seed> {
                preconditionFailure("Seed is not initialized")
            }, parent: self)
            let _: Provider<C.Root> = graph.provider()

            graph.finalize()
        }

        func provider<T>() -> T where T: AnyProvider {
            let rawType = T.unwrap()
            let key = BindingKey(type: rawType)

            if let provider = ancestorProviders[key] {
                return T.wrap { provider }
            }

            guard let parent = parent else {
                preconditionFailure("Unsatisfied dependency: \(rawType)")
            }

            let provider: T = parent.provider()
            ancestorProviders[key] = try! provider.unwrap()

            return provider
        }

        func build(_ seed: C.Seed) -> Graph {
            return Graph(component: componentInfo, seedProvider: Provider<C.Seed> {
                seed
            }, parent: self)
        }

        func rootProvider(_ seed: C.Seed) -> Provider<C.Root> {
            let graph = build(seed)
            let provider: Provider<C.Root> = graph.provider()

            graph.finalize()

            return provider
        }
    }
}
