//
//  Component.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol ComponentBuilderProtocol {
    associatedtype ComponentElement: Component
    
    func include(_ module: Module)
    func subcomponent<C: Component>(_ componentType: C.Type)
}

public protocol Component {
    associatedtype Root
    
    static func configure<Builder>(builder: Builder) where Builder : ComponentBuilderProtocol, Builder.ComponentElement == Self
}

public class ComponentBuilder<ComponentElement: Component>: ComponentBuilderProtocol {
    
    private let graph: Graph
    
    fileprivate init(graph: Graph) {
        self.graph = graph
    }
    
    public func include(_ module: Module) {
        module.register(container: graph)
    }
    
    public func subcomponent<C>(_ componentType: C.Type) where C : Component {
        graph.bind(ComponentBuilder<C>.self).to { _ in
            return Provider<ComponentBuilder<C>> {
                let subBuilder = ComponentBuilder<C>(graph: self.graph.createSubContainer())
                componentType.configure(builder: subBuilder)
                
                return subBuilder
            }
        }
    }
    
    public func build() -> ComponentElement.Root {
        let provider: Provider<ComponentElement.Root> = graph.provider()
        return provider.get()
    }
}

extension ComponentBuilderProtocol {
    
    public static func of(_ componentType: ComponentElement.Type) throws -> ComponentBuilder<ComponentElement> {
        let graph = Graph()
        let builder = ComponentBuilder<ComponentElement>(graph: graph)
        componentType.configure(builder: builder)
        
        try graph.validate(ComponentElement.Root.self)
        
        return builder
    }
}
