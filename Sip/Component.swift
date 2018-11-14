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
        module.register(binder: graph)
    }

    public func subcomponent<C>(_ componentType: C.Type) where C: Component {
        graph.bind(ComponentBuilder<C>.self).to {
            let subGraph = self.graph.createSubContainer()
            let subBuilder = ComponentBuilder<C>(graph: subGraph)
            componentType.configure(builder: subBuilder)
            componentType.configureRoot(binder: subGraph.bind(componentType.Root.self))

            return subBuilder
        }
    }
}
