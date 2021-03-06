//: [Previous](@previous)

import Sip

struct Parent {
    let strings: [String]
    let stringMap: [String: String]
    let childBuilder: ChildComponent.Builder
}

struct ParentModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(intoCollectionOf: String.self).to(value: "parent string 1")
        b.bind([String].self).intoCollection().to(value: "parent string 2")
        b.bind(intoMapOf: String.self).mapKey("a").to(value: "parent string A")
        b.bind([String: String].self).intoCollection().mapKey("b").to(value: "parent string B")
    }
}

struct ParentComponent: Component {
    typealias Root = Parent

    static func configureRoot<B>(binder: B) where B: BinderProtocol, ParentComponent.Root == B.Element {
        binder.to(factory: Parent.init)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(ParentModule())
        builder.subcomponent(ChildComponent.self)
    }
}

struct Child {
    let strings: [String]
    let stringMap: [String: String]
}

struct ChildModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(intoCollectionOf: String.self).to(value: "child string 3")
        b.bind(intoCollectionOf: String.self).to(value: "child string 4")
        b.bind(intoMapOf: String.self).mapKey("c").to(value: "child string C")
        b.bind(intoMapOf: String.self).mapKey("d").to(value: "child string D")
    }
}

struct ChildComponent: Component {
    typealias Root = Child

    static func configureRoot<B>(binder: B) where B: BinderProtocol, ChildComponent.Root == B.Element {
        binder.to(factory: Child.init)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(ChildModule())
    }
}

let parent = ParentComponent.builder().build()
let child = parent.childBuilder.build()

assert(parent.strings == ["parent string 1", "parent string 2"])
assert(Array(parent.stringMap.keys).sorted() == ["a", "b"])
assert(child.strings == ["parent string 1", "parent string 2", "child string 3", "child string 4"])
assert(Array(child.stringMap.keys).sorted() == ["a", "b", "c", "d"])

//: [Next](@next)
