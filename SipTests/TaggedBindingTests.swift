//
//  TaggedBindingTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/14.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private struct Foo {
    let value: String
}

private struct FooTag: Tag {
    typealias Element = Foo
}

private class Bar {
    let foo: Tagged<FooTag>
    init(foo: Tagged<FooTag>) {
        self.foo = foo
    }
}

private struct BarTag: Tag {
    typealias Element = Bar
}

private struct TestComponent: Component {
    struct Module: Sip.Module {
        func configure(binder b: BinderDelegate) {
            b.bind(String.self).to(value: "foo")
            b.bind(tagged: FooTag.self).to(factory: Foo.init)
        }
    }

    typealias Root = Tagged<BarTag>

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(Module())
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.tagged().to(factory: Bar.init)
    }
}

class TaggedBindingTests: XCTestCase {

    func testBindTagged() throws {
        let bar = try TestComponent.builder().build()

        XCTAssert(bar.value.foo.value.value == "foo")
    }
}
