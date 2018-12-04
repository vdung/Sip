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
    associatedtype Seed = Void
    typealias Builder = ComponentBuilder<Self>

    static func configureRoot<B>(binder: B) where B: BinderProtocol, B.Element == Root
    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol
}

public struct ComponentBuilder<ComponentElement: Component> {

    let builder: Graph.Builder<ComponentElement>

    public func build(_ seed: ComponentElement.Seed) -> ComponentElement.Root {
        let provider = builder.rootProvider(seed)
        return provider.get()
    }
}

public extension ComponentBuilder where ComponentElement.Seed == Void {
    public func build() -> ComponentElement.Root {
        return self.build(())
    }
}

extension ComponentBuilder {

    static func provider(file: StaticString=#file, line: Int=#line, function: StaticString=#function, componentInfo: ComponentInfo) -> ProviderInfo {
        let binding = Binding(file: file, line: line, function: function, bindingType: .unique, scope: Unscoped.self) { parent -> Provider<ComponentElement.Builder> in

            let graphBuilder = Graph.Builder<ComponentElement>(componentInfo: componentInfo, parent: parent)

            return Provider {
                self.init(builder: graphBuilder)
            }
        }

        let provider = ProviderInfo(component: componentInfo, binding: binding)
        provider.dependencies = [Provider<ComponentElement.Root>.self]

        return provider
    }
}

public extension Component {
    public static func builder() throws -> Builder {
        let componentInfo = ComponentInfo(parent: nil, componentType: Self.self)
        try componentInfo.finalize()

        return Builder(builder: Graph.Builder(componentInfo: componentInfo, parent: nil))
    }
}
