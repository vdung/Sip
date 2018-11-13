//: [Previous](@previous)

import Sip

class Bar {
    let foo: String
    
    init(foo: String) {
        self.foo = foo
    }
}

struct BarTag: Tag {
    typealias Element = Bar
}

class Baz {
    init() {}
}

class Qux {
    let bar: Tagged<BarTag>
    let baz: Baz
    let stringMap: [String: String]
    
    init(foo: String, bar: Tagged<BarTag>, baz: Baz, stringMap: [String: String]) {
        self.bar = bar
        self.baz = baz
        self.stringMap = stringMap
    }
}

struct BarBar {
    let bar: Bar
}

class Foobar {
    
    func injectProperty(
        foo: String,
        bar: Tagged<BarTag>,
        injectedBaz: Provider<Baz>,
        quxBuilder: ComponentBuilder<QuxComponent>,
        stringMap: Dictionary<String, String>
        ) {
        
        assert(foo == "foo")
        assert(bar.value.foo == foo)
        assert(quxBuilder.build() === quxBuilder.build())
        
        let baz = injectedBaz.get()
        let qux = quxBuilder.build()
        
        assert(bar.value !== qux.bar.value)
        assert(baz === qux.baz)
        assert(stringMap.count == 2)
        assert(stringMap["bar"] == "bar")
        assert(stringMap["baz"] == "baz")
        
        assert(qux.stringMap.count == 3)
        assert(qux.stringMap["bar"] == "bar")
        assert(qux.stringMap["baz"] == "baz")
        assert(qux.stringMap["qux"] == "qux")
    }
}

struct QuxComponent: Component {
    typealias Root = Qux
    
    struct QuxModule: Module {
        func register(binder b: BinderDelegate) {
            b.bind(intoMapOf: String.self).mapKey("qux").to(value: "qux")
        }
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, QuxComponent.Root == B.Element {
        binder.sharedInScope().to(factory: Qux.init)
    }
    
    static func configure<Builder>(builder: Builder) where QuxComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(QuxModule())
    }
}

struct ExampleComponent: Component {
    typealias Root = Injector<Foobar>
    
    struct ExampleModule: Module {
        func register(binder b: BinderDelegate) {
            b.bind(String.self).to(value: "foo")
            b.bind(intoMapOf: String.self).mapKey("bar").to(value: "bar")
            b.bind(intoMapOf: String.self).mapKey("baz").to(value: "baz")
            b.bind(tagged: BarTag.self).to(factory: Bar.init)
            b.bind(Baz.self).sharedInScope().to(factory: Baz.init)
        }
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, ExampleComponent.Root == B.Element {
        binder.to(injector: Foobar.injectProperty)
    }
    
    static func configure<Builder>(builder: Builder) where ExampleComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(ExampleModule())
        builder.subcomponent(QuxComponent.self)
    }
}

let foobarInjector: Injector<Foobar> = try ComponentBuilder.of(ExampleComponent.self).build()
foobarInjector.inject(Foobar())


//: [Next](@next)
