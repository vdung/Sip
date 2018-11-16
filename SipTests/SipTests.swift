//
//  SipTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/12.
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

private struct FooTest {
    func inject(
        foo: Foo,
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
            b.bind(String.self).to(value: "foo")
            b.bind(Foo.self).to(factory: Foo.init)
            b.bind(tagged: FooTag.self).to(factory: Foo.init)
            b.bind(intoCollectionOf: Foo.self).to(value: Foo(value: "a"))
            b.bind(intoMapOf: Foo.self).mapKey("b").to(value: Foo(value: "b"))
        }
    }

    typealias Root = Injector<FooTest>

    static func configure<Builder>(builder: Builder) where TestComponent == Builder.ComponentElement, Builder: ComponentBuilderProtocol {
        builder.include(Module())
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.to(injector: FooTest.inject)
    }
}

private struct InvalidComponent: Component {
    typealias Root = Injector<FooTest>
    
    static func configure<Builder>(builder: Builder) where InvalidComponent == Builder.ComponentElement, Builder : ComponentBuilderProtocol {
        
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, InvalidComponent.Root == B.Element {
        binder.to(injector: FooTest.inject)
    }
}

class SipTests: XCTestCase {

    func testAllUseCases() {
        XCTAssertNoThrow(try TestComponent.builder().build().inject(FooTest()))
    }
    
    func testValidationError() {
        XCTAssertThrowsError(try InvalidComponent.builder(), "Expected validation error") {
            guard let error = $0 as? ValidationError else {
                XCTFail("Expected a validation error")
                return
            }
            
            switch error {
            case .allErrors(let errors):
                XCTAssertEqual(errors.count, 5)
            default:
                XCTFail("Expected more than 1 errors")
            }
        }
    }

}
