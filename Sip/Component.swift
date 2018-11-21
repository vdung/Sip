//
//  Component.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol ComponentBuilderProtocol {

    func include(_ module: Module)
    func subcomponent<C: Component>(_ componentType: C.Type)
}

public protocol Component {
    associatedtype Root

    static func configureRoot<B>(binder: B) where B: BinderProtocol, B.Element == Root
    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol
}

public struct ComponentBuilder<ComponentElement: Component> {

    fileprivate let componentInfo: ComponentInfo
    
    public func build() -> ComponentElement.Root {
        let graph = componentInfo.buildGraph()
        let provider: Provider<ComponentElement.Root> = graph.provider()
        
        return provider.get()
    }
    
    static func binding(file: StaticString=#file, line: Int=#line, function: StaticString=#function, componentInfo: ComponentInfo) -> AnyBinding {
        return Binding(file: file, line: line, function: function, bindingType: .unique) { _ -> Provider<ComponentBuilder<ComponentElement>> in
            return Provider {
                self.init(componentInfo: componentInfo)
            }
        }
    }
}

public extension Component {
    public static func builder() throws -> ComponentBuilder<Self> {
        let componentInfo = ComponentInfo(parent: nil, componentType: Self.self)
        try componentInfo.validate()
        
        return ComponentBuilder(componentInfo: componentInfo)
    }
}
