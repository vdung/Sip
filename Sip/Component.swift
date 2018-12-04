//
//  Component.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol ComponentBuilderProtocol {

    func include(_ module: Module)
    func subcomponent<C>(_ componentType: C.Type) where C: Component
    func scope<S>(_ scope: S.Type) where S: Scope
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

public extension Component {
    public static func builder() throws -> Builder {
        let componentInfo = ComponentInfo(parent: nil, componentType: Self.self)
        try componentInfo.finalize()

        return Builder(builder: Graph.Builder(componentInfo: componentInfo, parent: nil))
    }
}
