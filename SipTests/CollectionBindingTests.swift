//
//  CollectionBindingTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/14.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private struct Inner {
    let strings: [String]
    let stringMap: [String: String]
}

private struct Parent {
    let inner: Inner
    let childBuilder: ChildComponent.Builder
}

private struct ParentModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(Inner.self).to(factory: Inner.init)
        b.bind(intoCollectionOf: String.self).to(value: "parent string 1")
        b.bind([String].self).intoCollection().to(value: "parent string 2")
        b.bind(intoMapOf: String.self).mapKey("a").to(value: "parent string A")
        b.bind([String: String].self).intoCollection().mapKey("b").to(value: "parent string B")
    }
}

private struct ParentComponent: Component {
    typealias Root = Parent

    static func configureRoot<B>(binder: B) where B: BinderProtocol, ParentComponent.Root == B.Element {
        binder.to(factory: Parent.init)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(ParentModule())
        builder.subcomponent(ChildComponent.self)
    }
}

private struct Child {
    let inner: Inner
}

private struct ChildModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind([String].self).elementsIntoCollection().to(value: ["child string 3", "child string 4"])
        b.bind([String: String].self).elementsIntoCollection().to(value: [
            "c": "child string C",
            "d": "child string D"])
    }
}

private struct ChildComponent: Component {
    typealias Root = Child

    static func configureRoot<B>(binder: B) where B: BinderProtocol, ChildComponent.Root == B.Element {
        binder.to(factory: Child.init)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(ChildModule())
    }
}

class CollectionBindingTests: XCTestCase {

    func testCollectionBinding() throws {
        let parent = try ParentComponent.builder().build()
        let child = parent.childBuilder.build()

        XCTAssertEqual(parent.inner.strings.sorted(), ["parent string 1", "parent string 2"])
        XCTAssertEqual(Array(parent.inner.stringMap.keys).sorted(), ["a", "b"])
        XCTAssertEqual(child.inner.strings.sorted(), ["child string 3", "child string 4", "parent string 1", "parent string 2"])
        XCTAssertEqual(Array(child.inner.stringMap.keys).sorted(), ["a", "b", "c", "d"])
    }
}
