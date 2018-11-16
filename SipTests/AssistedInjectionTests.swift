//
//  AssistedInjectionTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/15.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
import Sip

private struct Foo {
    let barFactory: Bar.Factory
    let baz: Int
    let qux: Bool

    var bar: Bar {
        return barFactory.create(qux)
    }

    struct Factory: AssistedInjectionFactoryProtocol {
        let create: (Bool) -> Foo
    }
}

private struct Bar {
    fileprivate typealias Factory = AssistedInjectionFactory<Bool, Bar>
    let bar: String
    let baz: Int
    let qux: Bool
}

private struct FooComponent: Component {
    fileprivate typealias Root = Foo.Factory

    struct Module: Sip.Module {
        func configure(binder: BinderDelegate) {
            binder.bind(String.self).to(value: "bar")
            binder.bind(Int.self).to(value: 2)
            binder.bind(factoryOf: Bar.self).to(elementFactory: Bar.init)
        }
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(Module())
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, FooComponent.Root == B.Element {
        binder.to(elementFactory: Foo.init)
    }
}

class AssistedInjectionTests: XCTestCase {

    func testAssistedInjection() {
        do {
            let fooFactory = try FooComponent.builder().build()
            let foo = fooFactory.create(true)
            XCTAssertEqual(foo.baz, 2)
            XCTAssertEqual(foo.qux, true)
            XCTAssertEqual(foo.bar.baz, 2)
            XCTAssertEqual(foo.bar.qux, true)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
}
