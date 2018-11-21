//
//  TaggedBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

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

private class TaggedBinding<UnderlyingBinding, TagType> : DelegatedBinding, BindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, TagType: Tag, TagType.Element == UnderlyingBinding.Element.Element {
    typealias Element = ThrowingProvider<Tagged<TagType>>

    private let underlyingBinding: UnderlyingBinding

    var delegate: AnyBinding {
        return underlyingBinding
    }
    
    required convenience init(copy: TaggedBinding<UnderlyingBinding, TagType>) {
        self.init(binding: UnderlyingBinding(copy: copy.underlyingBinding))
    }

    init(binding: UnderlyingBinding) {
        self.underlyingBinding = binding
    }

    func createElement(provider: ProviderProtocol) -> ThrowingProvider<Tagged<TagType>> {
        let p = underlyingBinding.createElement(provider: provider)
        return ThrowingProvider {
            return Tagged<TagType>(value: try p.get())
        }
    }
}

public class TaggedBinder<B, TagType>: BinderDecorator where B: BinderProtocol, TagType: Tag, B.Element == Tagged<TagType> {
    public typealias Wrapped = B
    public typealias Element = TagType.Element

    private let binder: B

    required init(binder: B) {
        self.binder = binder
    }

    public func register<B>(binding: B) where B: BindingBase, TagType.Element == B.Element.Element, B.Element: ProviderBase {
        return binder.register(binding: TaggedBinding<B, TagType>(binding: binding))
    }
}

extension BinderProtocol {

    public func tagged<T>() -> TaggedBinder<Self, T> where T: Tag, Self.Element == Tagged<T> {
        return decorate()
    }
}

public extension BinderDelegate {

    public func bind<T: Tag>(tagged tag: T.Type) -> TaggedBinder<Binder<Tagged<T>>, T> {
        return bind(Tagged<T>.self).decorate()
    }
}
