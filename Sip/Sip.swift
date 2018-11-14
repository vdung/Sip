//
//  Sip.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public struct ComponentBuilders {

    public static func of<C>(_ componentType: C.Type) throws -> ComponentBuilder<C> where C: Component {
        let graph = Graph()
        let builder = ComponentBuilder<C>(graph: graph)
        componentType.configure(builder: builder)
        componentType.configureRoot(binder: graph.bind(componentType.Root.self))

        try graph.validate(C.Root.self)

        return builder
    }
}
