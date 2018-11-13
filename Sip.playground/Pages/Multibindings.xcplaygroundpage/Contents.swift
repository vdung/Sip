//: [Previous](@previous)


import Sip

struct Parent {
    let strings: [String]
    let stringMap: [String: String]
    let childBuilder: ComponentBuilder<ChildComponent>
}

struct ParentModule: Module {
    func register(binder b: BinderDelegate) {
        b.bindIntoCollectionOf(String.self).to(value: "parent string 1")
        b.bindIntoCollectionOf(String.self).to(value: "parent string 2")
        b.bindIntoMapOf(String.self).mapKey("a").to(value: "parent string A")
        b.bindIntoMapOf(String.self).mapKey("b").to(value: "parent string B")
    }
}

struct ParentComponent: Component {
    typealias Root = Parent
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, ParentComponent.Root == B.Element {
        binder.to(factory: Parent.init)
    }
    
    static func configure<Builder>(builder: Builder) where ParentComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(ParentModule())
        builder.subcomponent(ChildComponent.self)
    }
}

struct Child {
    let strings: [String]
    let stringMap: [String: String]
}

struct ChildModule: Module {
    func register(binder b: BinderDelegate) {
        b.bindIntoCollectionOf(String.self).to(value: "child string 3")
        b.bindIntoCollectionOf(String.self).to(value: "child string 4")
        b.bindIntoMapOf(String.self).mapKey("c").to(value: "child string C")
        b.bindIntoMapOf(String.self).mapKey("d").to(value: "child string D")
    }
}

struct ChildComponent: Component {
    typealias Root = Child
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, ChildComponent.Root == B.Element {
        binder.to(factory: Child.init)
    }
    
    static func configure<Builder>(builder: Builder) where ChildComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(ChildModule())
    }
}

let parent = ComponentBuilder.of(ParentComponent.self).build()
let child = parent.childBuilder.build()

assert(parent.strings == ["parent string 1", "parent string 2"])
assert(Array(parent.stringMap.keys).sorted() == ["a", "b"])
assert(child.strings == ["parent string 1", "parent string 2", "child string 3", "child string 4"])
assert(Array(child.stringMap.keys).sorted() == ["a", "b", "c", "d"])


//: [Next](@next)
