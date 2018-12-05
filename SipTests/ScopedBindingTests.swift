//
//  ScopedBindingTests.swift
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
    let bazBuilder: Provider<BazComponent.Builder>

    init(foo: Foo, fooProvider: Provider<Foo>, bazBuilder: Provider<BazComponent.Builder>) {
        self.foo = foo
        self.fooProvider = fooProvider
        self.bazBuilder = bazBuilder
    }
}

private class Baz {
    let foo: Foo
    init(foo: Foo) {
        self.foo = foo
    }
}

private struct BazScoped: Scope {}

private struct BazComponent: Component {
    typealias Root = Baz

    static func configureRoot<B>(binder: B) where B: BinderProtocol, BazComponent.Root == B.Element {
        binder.inScope(BazScoped.self).to(factory: Baz.init)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.scope(BazScoped.self)
    }
}

private struct InvalidBazComponent: Component {
    typealias Root = Foo
    typealias Seed = String
    
    static func configureRoot<B>(binder: B) where B: BinderProtocol, InvalidBazComponent.Root == B.Element {
        binder.inScope(BazScoped.self).to(factory: Foo.init)
    }
    
    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
    }
}

private class TestOperation {
    
    var foo: Foo?
    let fooProvider: Provider<Foo>
    
    init(fooProvider: Provider<Foo>) {
        self.fooProvider = fooProvider
    }
    
    func dispatch(queue: DispatchQueue, group: DispatchGroup) {
        queue.async(group: group, execute: DispatchWorkItem {
            self.foo = self.fooProvider.get()
        })
    }
}

private struct TestScoped: Scope {}
private struct TestModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(String.self).to(value: "foo")
        b.bind(Foo.self).inScope(TestScoped.self).to(factory: Foo.init)
        b.bind(TestOperation.self).to(factory: TestOperation.init)
    }
}

private struct TestComponent: Component {
    
    typealias Root = Bar

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(TestModule())
        builder.subcomponent(BazComponent.self)
        builder.scope(TestScoped.self)
    }

    static func configureRoot<B>(binder: B) where B: BinderProtocol, TestComponent.Root == B.Element {
        binder.to(factory: Bar.init)
    }
}

private struct MultiThreadTestModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(String.self).to(value: "foo")
        b.bind(Foo.self).inScope(TestScoped.self).to { (value: String) in
            usleep(1000)
            return Foo(value: value)
        }
        b.bind(TestOperation.self).to(factory: TestOperation.init)
    }
}
private struct MultiThreadTestComponent: Component {
    let operatorProvider: Provider<TestOperation>
    
    typealias Root = MultiThreadTestComponent
    
    static func configure<Builder>(builder: Builder) where Builder : ComponentBuilderProtocol {
        builder.include(MultiThreadTestModule())
        builder.scope(TestScoped.self)
    }
    
    static func configureRoot<B>(binder: B) where B : BinderProtocol, MultiThreadTestComponent.Root == B.Element {
        binder.to(factory: MultiThreadTestComponent.init)
    }
}

class ScopeBindingTests: XCTestCase {

    func testBindScope() throws {
        let barBuilder = try TestComponent.builder()
        let bar = barBuilder.build()
        let anotherBar = barBuilder.build()

        XCTAssert(bar !== anotherBar, "Same instance of bar")
        XCTAssert(bar.foo === bar.fooProvider.get(), "Multiple instances of foo")
        XCTAssert(bar.foo !== anotherBar.foo, "Same instance of foo")

        let baz = bar.bazBuilder.get().build()
        let anotherBaz = bar.bazBuilder.get().build()

        XCTAssert(baz !== anotherBaz, "Same instance of baz")
        XCTAssert(bar.foo === baz.foo, "Different foo instance in child component")
    }
    
    func testBindScopeError() {
        XCTAssertThrowsError(try InvalidBazComponent.builder().build("foo"), "Invalid scoped binding should throw") {
            guard let error = $0 as? ValidationError else {
                XCTFail("Expected a validation error")
                return
            }
            
            switch error {
            case .conflictingScopes(let componentScopes, let binding):
                XCTAssertTrue(componentScopes.isEmpty)
                XCTAssertTrue(binding.scope == BazScoped.self)
            default:
                XCTFail("Expected a conflicting scope error")
            }
        }
    }
    
    func testMultiThread() throws {
        let numThread = 10
        let queue = DispatchQueue(label: "Sip.ScopedBindingTests", attributes: .concurrent)
        let group = DispatchGroup()
        
        let component = try MultiThreadTestComponent.builder().build()
        var opts = [TestOperation]()
        
        for _ in 0..<numThread {
            let opt = component.operatorProvider.get()
            opts.append(opt)
        }
        
        opts.forEach { $0.dispatch(queue: queue, group: group) }
        group.wait()
        
        let fooSet = Set<ObjectIdentifier>(opts.map { ObjectIdentifier($0.foo!) })
        XCTAssertEqual(fooSet.count, 1)
    }
}
