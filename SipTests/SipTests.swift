//
//  SipTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/12.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private protocol FooProtocol {

}

private struct Foo: FooProtocol {
    let value: String
}

private struct FooTag: Tag {
    typealias Element = Foo
}

private struct FooTest {
    func inject(
        fooProtocol: FooProtocol,
        foo: Foo,
        fooOptional: Foo?,
        fooProvider: Provider<Foo>,
        fooTagged: Tagged<FooTag>,
        fooArray: [Foo],
        fooDict: [String: Foo]
        ) {
    }
}

private struct TestComponent: Component {
    struct Module: Sip.Module {
        func configure(binder b: BinderDelegate) {
            b.bind(FooProtocol.self).to(factory: Foo.init)
            b.bind(Foo.self).to(factory: Foo.init)
            b.bind(Optional<Foo>.self).to(factory: Foo.init)
            b.bind(tagged: FooTag.self).to(factory: Foo.init)
            b.bind(intoCollectionOf: Foo.self).to(value: Foo(value: "a"))
            b.bind(intoMapOf: Foo.self).mapKey("b").to(value: Foo(value: "b"))
        }
    }

    typealias Root = Injector<FooTest>
    typealias Seed = String

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(Module())
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.to(injector: FooTest.inject)
    }
}

private struct InvalidChildComponent: Component {
    typealias Root = Injector<FooTest>

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, InvalidChildComponent.Root == B.Element {
        binder.to(injector: FooTest.inject)
    }
}

private struct InvalidComponent: Component {
    typealias Root = InvalidComponent

    let fooBuilder: TestComponent.Builder
    let invalidChildBuilder: InvalidChildComponent.Builder

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.subcomponent(TestComponent.self)
        builder.subcomponent(InvalidChildComponent.self)
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, InvalidComponent.Root == B.Element {
        binder.to(factory: InvalidComponent.init)
    }
}

class SipTests: XCTestCase {

    func testAllUseCases() {
        XCTAssertNoThrow(try TestComponent.builder().build("foo").inject(FooTest()))
    }

    func testValidationError() {
        XCTAssertThrowsError(try InvalidComponent.builder(), "Expected validation error") {
            guard let error = $0 as? ValidationError else {
                XCTFail("Expected a validation error")
                return
            }
            
            switch error {
            case .multipleErrors(let errors):
                XCTAssertEqual(errors.count, 7)
            default:
                XCTFail("Expected more than 1 errors")
            }
        }
    }

}
