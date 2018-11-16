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
    fileprivate var provider: Provider<ComponentElement.Root> {
        return graph.provider()
    }

    init(graph: Graph) {
        self.graph = graph
    }
    
    func validate() throws {
        guard let binding = graph.getBinding(forType: ComponentElement.Root.self) else {
            throw ValidationError.rootNotConfigured(component: ComponentElement.self)
        }
        
        let validator = Validator(container: graph)
        validator.validate(binding: binding, resolvedType: ComponentElement.Root.self)
        
        errors.append(contentsOf: validator.errors)
        
        if errors.count > 1 {
            throw ValidationError.multipleErrors(errors)
        }
        if errors.count == 1 {
            throw errors[0]
        }
    }

    public func build() -> ComponentElement.Root {
        return provider.get()
    }
}

extension ComponentBuilder: ComponentBuilderProtocol {

    public func include(_ module: Module) {
        module.configure(binder: graph)
    }

    public func subcomponent<C>(_ componentType: C.Type) where C: Component {
        graph.bind(ComponentBuilder<C>.self).to {
            let subBuilder = C.builder(graph: self.graph.createSubContainer())
            
            do {
                try subBuilder.validate()
            } catch let e as ValidationError {
                switch (e) {
                case .multipleErrors(let errors):
                    self.errors.append(contentsOf: errors)
                default:
                    self.errors.append(e)
                }
            }

            return subBuilder
        }
    }
}

public extension Component {
    fileprivate static func builder(graph: Graph) -> ComponentBuilder<Self> {
        let builder = ComponentBuilder<Self>(graph: graph)
        configure(builder: builder)
        configureRoot(binder: graph.bind(Root.self))
        
        
        return builder
    }
    
    public static func builder() throws -> ComponentBuilder<Self> {
        let b = builder(graph: Graph())
        try b.validate()
        return b
    }
}
