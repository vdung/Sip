//
//  MemoryManagementTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/26.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private class Foo {
    init() {}
}

private class SubComponent: Component {
    typealias Root = SubComponent

    let foo: Foo

    init(foo: Foo) {
        self.foo = foo
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, SubComponent.Root == B.Element {
        binder.to(factory: SubComponent.init)
    }
}

private class TestComponent: Component {
    typealias Root = TestComponent
    let foo: Foo
    let subComponent: SubComponent.Builder

    init(foo: Foo, subComponent: SubComponent.Builder) {
        self.foo = foo
        self.subComponent = subComponent
    }

    struct Module: Sip.Module {

        let foo = Foo()

        func configure(binder: BinderDelegate) {
            binder.bind(Foo.self).to(value: self.foo)
        }
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(Module())
        builder.subcomponent(SubComponent.self)
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.to(factory: TestComponent.init)
    }
}

class MemoryManagementTests: XCTestCase {

    func testMemoryManagement() throws {
        weak var foo: Foo?
        weak var component: TestComponent?
        weak var subComponent: SubComponent?

        try autoreleasepool {
            let componentBuilder = try TestComponent.builder()
            let c = componentBuilder.build()
            component = c
            foo = c.foo
            subComponent = c.subComponent.build()

            XCTAssertNotNil(foo)
        }

        XCTAssertNil(subComponent, "subComponent is not nil")
        XCTAssertNil(component, "component is not nil")
        XCTAssertNil(foo, "foo is not nil")
    }

}
