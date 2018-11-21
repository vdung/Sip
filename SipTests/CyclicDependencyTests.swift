//
//  CyclicDependencyTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/16.
//

import XCTest
@testable import Sip


private struct Foo {
    let bar: Provider<Bar>
}

private struct Bar {
    let foo: Foo
}

private struct TestComponent: Component {
    typealias Root = Foo
    struct Module: Sip.Module {
        func configure(binder: BinderDelegate) {
            binder.bind(Bar.self).to(factory: Bar.init)
        }
    }
    
    static func configure<Builder>(builder: Builder) where Builder : ComponentBuilderProtocol {
        builder.include(Module())
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, Root == B.Element {
        binder.to(factory: Foo.init)
    }
}

private class A {
    init(b: B) {}
}

private class B {
    init(c: C) {}
}

private struct C {
    init(a: A) {}
}

private struct InvalidComponent: Component {
    typealias Root = A
    struct Module: Sip.Module {
        func configure(binder: BinderDelegate) {
            binder.bind(B.self).to(factory: B.init)
            binder.bind(C.self).to(factory: C.init)
        }
    }
    
    static func configure<Builder>(builder: Builder) where Builder : ComponentBuilderProtocol {
        builder.include(Module())
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, InvalidComponent.Root == B.Element {
        binder.to(factory: A.init)
    }
}

class CyclicDependencyTests: XCTestCase {
    
    func testCyclicDependency() {
        XCTAssertNoThrow(try TestComponent.builder().build())
    }
    
    func testCyclicDependecyFail() {
        XCTAssertThrowsError(try InvalidComponent.builder().build(), "Expected error") {
            guard let error = $0 as? ValidationError else {
                XCTFail("Expected validation error")
                return
            }
            switch (error) {
            case .cyclicDependency(let cycle):
                XCTAssertEqual(cycle.count, 3)
            default:
                XCTFail("Expected cyclic dependency error")
            }
        }
    }
}
