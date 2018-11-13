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

fileprivate class TaggedBinding<UnderlyingBinding, TagType> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, TagType: Tag, TagType.Element == UnderlyingBinding.Element.Element {
    typealias Element = Provider<Tagged<TagType>>
    
    private let underlyingBinding: UnderlyingBinding
    
    var delegate: AnyBinding {
        return underlyingBinding
    }
    
    init(binding: UnderlyingBinding) {
        self.underlyingBinding = binding
    }
    
    func createElement(provider: ProviderProtocol) -> Provider<Tagged<TagType>> {
        let p = underlyingBinding.createElement(provider: provider)
        return Provider {
            return Tagged<TagType>(value: p.get())
        }
    }
    
    func copy() -> AnyBinding {
        return TaggedBinding(binding: underlyingBinding)
    }
}

public class TaggedBinder<B, TagType>: BinderDecorator where B: BinderProtocol, TagType: Tag, B.Element == Tagged<TagType> {
    public typealias Wrapped = B
    public typealias Element = TagType.Element
    
    private let binder: B
    
    required init(binder: B) {
        self.binder = binder
    }
    
    public func register<B>(binding: B) where B : BindingBase, TagType.Element == B.Element.Element, B.Element : ProviderBase {
        return binder.register(binding: TaggedBinding<B, TagType>(binding: binding))
    }
}

extension BinderProtocol {
    
    public func tagged<T>() -> TaggedBinder<Self, T> where T: Tag, Self.Element == Tagged<T> {
        return decorate()
    }
}

public extension BinderDelegate {
    
    public func bindTagged<T: Tag>(_ tag: T.Type) -> TaggedBinder<Binder<Tagged<T>>, T> {
        return bind(Tagged<T>.self).decorate()
    }
}
