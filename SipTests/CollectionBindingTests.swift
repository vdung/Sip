//
//  CollectionBindingTests.swift
//  SipTests
//
//  Created by Cao Viet Dung on 2018/11/14.
//  Copyright © 2018 Cao Viet Dung. All rights reserved.
//

import XCTest
@testable import Sip

private struct Parent {
    let strings: [String]
    let stringMap: [String: String]
    let childBuilder: ChildComponent.Builder
}

private struct ParentModule: Module {
    func configure(binder b: BinderDelegate) {
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
    let strings: [String]
    let stringMap: [String: String]
}

private struct ChildModule: Module {
    func configure(binder b: BinderDelegate) {
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
        let parent: ParentComponent.Root
        do {
            parent = try ParentComponent.builder().build()
        } catch let e {
            print(e)
            throw e
        }
        let child = parent.childBuilder.build()

        XCTAssertEqual(parent.strings, ["parent string 1", "parent string 2"])
        XCTAssertEqual(Array(parent.stringMap.keys).sorted(), ["a", "b"])
        XCTAssertEqual(child.strings, ["parent string 1", "parent string 2", "child string 3", "child string 4"])
        XCTAssertEqual(Array(child.stringMap.keys).sorted(), ["a", "b", "c", "d"])
    }
}
