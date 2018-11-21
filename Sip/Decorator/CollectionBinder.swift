//
//  CollectionBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol CollectionBindingResult {
    associatedtype Element
    static func create(_ element: Element) -> Self
    mutating func mergeWith(_ other: Self) -> Self
}

extension Array: CollectionBindingResult {
    public static func create(_ element: Element) -> Array<Element> {
        return [element]
    }

    public mutating func mergeWith(_ other: Array<Element>) -> Array<Element> {
        self.append(contentsOf: other)
        return self
    }
}

extension Dictionary: CollectionBindingResult {
    public static func create(_ element: (key: Key, value: Value)) -> Dictionary<Key, Value> {
        return Dictionary(dictionaryLiteral: element)
    }

    public mutating func mergeWith(_ other: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        self.merge(other) { (value1, value2) -> Value in
            preconditionFailure("Duplicate keys for different binding: \(value1), \(value2)")
        }
        return self
    }
}

private class CollectionBinding<UnderlyingBinding, CollectionType>: DelegatedBinding, BindingBase where CollectionType: CollectionBindingResult, UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, UnderlyingBinding.Element.Element == CollectionType.Element {

    typealias Element = ThrowingProvider<CollectionType>
    typealias CollectionBindingType = CollectionBinding<UnderlyingBinding, CollectionType>

    private let collectionType: CollectionType.Type
    private let firstBinding: UnderlyingBinding
    private var bindings: [AnyBinding]

    var delegate: AnyBinding {
        return firstBinding
    }

    var bindingType: BindingType {
        return BindingType.collection(self.addBinding)
    }
    
    required convenience init(copy: CollectionBinding<UnderlyingBinding, CollectionType>) {
        self.init(collectionType: copy.collectionType, firstBinding: UnderlyingBinding(copy: copy.firstBinding), otherBindings: copy.bindings.map { $0.copy() })
    }

    init(collectionType: CollectionType.Type, firstBinding: UnderlyingBinding, otherBindings: [AnyBinding]) {
        self.collectionType = collectionType
        self.firstBinding = firstBinding
        self.bindings = otherBindings
    }

    convenience init(collectionType: CollectionType.Type, binding: UnderlyingBinding) {
        self.init(collectionType: collectionType, firstBinding: binding, otherBindings: [CollectionBindingType]())
    }

    private func addBinding(_ binding: AnyBinding) {
        guard let providerType = binding.element as? AnyProvider.Type else {
            preconditionFailure("Expected a binding of a provider, got \(binding)")
        }
        if providerType.element != Element.Element.self {
            preconditionFailure("Expected a binding for \(Element.Element.self), got \(binding)")
        }
        bindings.append(binding)
    }

    func createElement(provider: ProviderProtocol) -> ThrowingProvider<CollectionType> {
        let firstProvider = firstBinding.createElement(provider: provider)
        let addedProviders = bindings.map { Element(wrapped: $0.createProvider(provider: provider)) }

        return ThrowingProvider {
            try addedProviders.reduce(self.collectionType.create(try firstProvider.get()), { (result, p) in
                var newResult = result
                return newResult.mergeWith(try p.get())
            })
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
        return binder.register(binding: CollectionBinding(collectionType: CollectionType.self, binding: binding))
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
