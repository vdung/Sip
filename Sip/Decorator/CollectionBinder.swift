//
//  CollectionBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

private class CollectionBinding<UnderlyingBinding, CollectionType>: DelegatedBinding, CollectionBindingBase where CollectionType: CollectionBindingResult, UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, UnderlyingBinding.Element.Element == CollectionType.Element {
    
    typealias Element = ThrowingProvider<CollectionType>

    private let firstBinding: UnderlyingBinding
    var bindings: [AnyBinding]

    var delegate: AnyBinding {
        return firstBinding
    }
    
    var bindingType: BindingType {
        return BindingType.collection({ [unowned self] in
            self.addBinding($0)
        })
    }
    
    required convenience init(copy: CollectionBinding<UnderlyingBinding, CollectionType>) {
        self.init(firstBinding: UnderlyingBinding(copy: copy.firstBinding), otherBindings: copy.bindings.map { $0.copy() })
    }
    
    convenience init(binding: UnderlyingBinding) {
        self.init(firstBinding: binding, otherBindings: [AnyBinding]())
    }

    init(firstBinding: UnderlyingBinding, otherBindings: [AnyBinding]) {
        self.firstBinding = firstBinding
        self.bindings = otherBindings
    }
    
    func initialElementProvider(provider: ProviderProtocol) -> ThrowingProvider<CollectionType> {
        let firstProvider = firstBinding.createElement(provider: provider)
        return ThrowingProvider {
            CollectionType(elements: try firstProvider.get())
        }
    }
}

public class CollectionBinder<Wrapped>: BinderDecorator where Wrapped: BinderProtocol, Wrapped.Element: CollectionBindingResult {

    public typealias CollectionType = Wrapped.Element
    public typealias Element = CollectionType.Element

    private let binder: Wrapped

    required init(binder: Wrapped) {
        self.binder = binder
    }

    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        return binder.register(binding: CollectionBinding(binding: binding))
    }
}

extension BinderProtocol where Element: CollectionBindingResult {
    public func intoCollection() -> CollectionBinder<Self> {
        return decorate()
    }
}

public extension BinderDelegate {

    public func bind<T>(intoCollectionOf type: T.Type) -> CollectionBinder<Binder<[T]>> {
        return bind([T].self).decorate()
    }

    public func bind<Key: Hashable, T>(intoMapOf type: T.Type) -> CollectionBinder<Binder<[Key: T]>> {
        return bind([Key: T].self).decorate()
    }
}
