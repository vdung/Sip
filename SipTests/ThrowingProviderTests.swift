//
//  ThrowingProviderTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/16.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private struct Foo {
    init() throws {
        throw FooError.foo
    }
}

private struct Bar {
    
}

private enum FooError: Error {
    case foo
}

private struct Test {
    let fooProvider: ThrowingProvider<Foo>
    let barProvider: ThrowingProvider<Bar>
}

private struct TestComponent: Component {
    typealias Root = Test
    struct Module: Sip.Module {
        func configure(binder: BinderDelegate) {
            binder.bind(Foo.self).to(factory: Foo.init)
            binder.bind(Bar.self).to(factory: Bar.init)
        }
    }
    
    static func configure<Builder>(builder: Builder) where TestComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        builder.include(Module())
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, Root == B.Element {
        binder.to(factory: Test.init)
    }
}

class ThrowingProviderTests: XCTestCase {

    func testThrowingProvider() {
        let test = try! TestComponent.builder().build()
        XCTAssertThrowsError(try test.fooProvider.get())
        XCTAssertNoThrow(try test.barProvider.get())
    }

}
