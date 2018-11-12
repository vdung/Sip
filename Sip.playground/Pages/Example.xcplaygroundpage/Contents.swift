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

class Quxx {
    let bar: Tagged<BarTag>
    let baz: Baz
    
    init(foo: String, bar: Tagged<BarTag>, baz: Baz) {
        self.bar = bar
        self.baz = baz
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
        quxBuilder: ComponentBuilder<QuxComponent>
        ) {
        
        assert(foo == "foo")
        assert(bar.value.foo == foo)
        assert(quxBuilder.build() === quxBuilder.build())
        
        let baz = injectedBaz.get()
        let qux = quxBuilder.build()
        
        assert(bar.value !== qux.bar.value)
        assert(baz === qux.baz)
    }
}

struct QuxComponent: Component {
    typealias Root = Quxx
    
    struct QuxModule: Module {
        func register(container c: Container) {
            c.bind(Quxx.self).sharedInScope().to(factory: Quxx.init)
        }
    }
    
    static func configure<Builder>(builder: Builder) where QuxComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(QuxModule())
    }
}

struct ExampleComponent: Component {
    typealias Root = Injector<Foobar>
    
    struct ExampleModule: Module {
        func register(container c: Container) {
            c.bind(String.self).to(value: "foo")
            c.bindTagged(BarTag.self).to(factory: Bar.init)
            c.bind(Baz.self).sharedInScope().to(factory: Baz.init)
            c.bindInjectorOf(Foobar.self).to(injector: Foobar.injectProperty)
        }
    }
    
    static func configure<Builder>(builder: Builder) where ExampleComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(ExampleModule())
        builder.subcomponent(QuxComponent.self)
    }
}

let foobarInjector: Injector<Foobar> = try ComponentBuilder.of(ExampleComponent.self).build()
foobarInjector.inject(Foobar())


//: [Next](@next)
