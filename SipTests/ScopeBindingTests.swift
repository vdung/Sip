//
//  ScopeBindingTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/14.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private class Foo {
    let value: String

    init(value: String) {
        self.value = value
    }
}

private class Bar {
    let foo: Foo
    let fooProvider: Provider<Foo>
    let bazBuilder: Provider<ComponentBuilder<BazComponent>>

    init(foo: Foo, fooProvider: Provider<Foo>, bazBuilder: Provider<ComponentBuilder<BazComponent>>) {
        self.foo = foo
        self.fooProvider = fooProvider
        self.bazBuilder = bazBuilder
    }
}

private class Baz {
    init() {}
}

private struct BazComponent: Component {
    typealias Root = Baz

    static func configureRoot<B>(binder: B) where B: BinderProtocol, BazComponent.Root == B.Element {
        binder.sharedInScope().to(factory: Baz.init)
    }

    static func configure<Builder>(builder: Builder) where BazComponent == Builder.ComponentElement, Builder: ComponentBuilderProtocol {
    }
}

private struct TestComponent: Component {
    struct Module: Sip.Module {
        func configure(binder b: BinderDelegate) {
            b.bind(String.self).to(value: "foo")
            b.bind(Foo.self).sharedInScope().to(factory: Foo.init)
        }
    }

    typealias Root = Bar

    static func configure<Builder>(builder: Builder) where TestComponent == Builder.ComponentElement, Builder: ComponentBuilderProtocol {
        builder.include(Module())
        builder.subcomponent(BazComponent.self)
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.sharedInScope().to(factory: Bar.init)
    }
}

class ScopeBindingTests: XCTestCase {

    func testBindScope() {
        let barBuilder = try! ComponentBuilders.of(TestComponent.self)
        let bar = barBuilder.build()
        let anotherBar = barBuilder.build()

        XCTAssert(bar === anotherBar, "Multiple instances of bar")
        XCTAssert(bar.foo === bar.fooProvider.get(), "Multiple instances of foo")

        let baz = bar.bazBuilder.get().build()
        let anotherBaz = bar.bazBuilder.get().build()

        XCTAssert(baz !== anotherBaz, "Same instance of baz")
    }
}
