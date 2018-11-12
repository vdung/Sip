//
//  TaggedBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol Tag {
    associatedtype Element
}

public struct Tagged<T: Tag> {
    public typealias Tag = T
    public typealias Element = T.Element
    public let value: T.Element
    
    public init(value: T.Element) {
        self.value = value
    }
}

public extension ProviderBase {
    func tagged<TagType: Tag>() -> Provider<Tagged<TagType>> where TagType.Element == Element {
        return to { value in Tagged(value: value) }
    }
}

public class TaggedBinder<B, TagType>: BinderDecorator where B: BinderProtocol, TagType: Tag, B.Element == Tagged<TagType> {
    public typealias Wrapped = B
    public typealias Element = TagType.Element
    
    private let binder: B
    
    required init(binder: B) {
        self.binder = binder
    }
    
    public func to(binding: Binding<Provider<Element>>) {
        binder.to(binding: binding.convert { create in { p in create(p).tagged() }})
    }
}

extension BinderProtocol {
    
    public func tagged<T>() -> TaggedBinder<Self, T> where T: Tag, Self.Element == Tagged<T> {
        return decorate()
    }
}

public extension Container {
    
    public func bindTagged<T: Tag>(_ tag: T.Type) -> TaggedBinder<Binder<Tagged<T>>, T> {
        return Binder(elementType: Tagged<T>.self, bindFunc: self.register)
            .decorate()
    }
}
