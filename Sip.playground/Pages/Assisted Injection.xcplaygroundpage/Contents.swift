//: [Previous](@previous)

import Foundation
import Sip

struct Foo {
    let barFactory: Bar.Factory
    let baz: Int
    let qux: Bool
    
    var bar: Bar {
        return barFactory.create(qux)
    }
}

struct Bar {
    typealias Factory = AssistedInjectionFactory<Bool, Bar>
    let bar: String
    let baz: Int
    let qux: Bool
}

struct FooComponent: Component {
    typealias Root = AssistedInjectionFactory<Bool, Foo>

    struct Module: Sip.Module {
        func configure(binder: BinderDelegate) {
            binder.bind(String.self).to(value: "bar")
            binder.bind(Int.self).to(value: 2)
            binder.bind(factoryOf: Bar.self).to(elementFactory: Bar.init)
        }
    }

    static func configure<Builder>(builder: Builder) where FooComponent == Builder.ComponentElement, Builder: ComponentBuilderProtocol {
        builder.include(Module())
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, FooComponent.Root == B.Element {
        binder.to(elementFactory: Foo.init)
    }
}

let factory = FooComponent.builder().build()
print(factory.create(false))
print(factory.create(false).bar)

