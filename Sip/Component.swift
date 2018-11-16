//
//  Component.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol ComponentBuilderProtocol {
    associatedtype ComponentElement: Component

    func include(_ module: Module)
    func subcomponent<C: Component>(_ componentType: C.Type)
}

public protocol Component {
    associatedtype Root

    static func configureRoot<B>(binder: B) where B: BinderProtocol, B.Element == Root
    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol, Builder.ComponentElement == Self
}

public class ComponentBuilder<ComponentElement: Component> {

    fileprivate let graph: Graph
    fileprivate var errors: [ValidationError] = []

    init(graph: Graph) {
        self.graph = graph
    }

    public func build() -> ComponentElement.Root {
        let provider: Provider<ComponentElement.Root> = graph.provider()
        return provider.get()
    }
}

extension ComponentBuilder: ComponentBuilderProtocol {

    public func include(_ module: Module) {
        module.configure(binder: graph)
    }

    public func subcomponent<C>(_ componentType: C.Type) where C: Component {
        graph.bind(ComponentBuilder<C>.self).to {
            let subGraph = self.graph.createSubContainer()
            let subBuilder = ComponentBuilder<C>(graph: subGraph)
            let validator = ValidationBinder(elementType: componentType.Root.self, container: subGraph)
            componentType.configure(builder: subBuilder)
            componentType.configureRoot(binder: validator)
            
            self.errors.append(contentsOf: validator.errors + subBuilder.errors)

            return subBuilder
        }
    }
}

public extension Component {
    public static func builder() throws -> ComponentBuilder<Self> {
        let graph = Graph()
        let builder = ComponentBuilder<Self>(graph: graph)
        let validator = ValidationBinder(elementType: Root.self, container: graph)
        configure(builder: builder)
        configureRoot(binder: validator)

        let errors = validator.errors + builder.errors
        if errors.count > 1 {
            throw ValidationError.allErrors(errors)
        }
        if errors.count == 1 {
            throw errors[0]
        }

        return builder
    }
}
