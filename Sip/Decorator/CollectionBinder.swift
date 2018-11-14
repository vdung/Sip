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

    typealias Element = Provider<CollectionType>
    typealias CollectionBindingType = CollectionBinding<UnderlyingBinding, CollectionType>

    private let collectionType: CollectionType.Type
    private let firstBinding: UnderlyingBinding
    private var bindings: [CollectionBindingType]

    var delegate: AnyBinding {
        return firstBinding
    }

    var bindingType: BindingType {
        return BindingType.collection(self.addBinding)
    }

    init(collectionType: CollectionType.Type, firstBinding: UnderlyingBinding, otherBindings: [CollectionBindingType]) {
        self.collectionType = collectionType
        self.firstBinding = firstBinding
        self.bindings = otherBindings
    }

    convenience init(collectionType: CollectionType.Type, binding: UnderlyingBinding) {
        self.init(collectionType: collectionType, firstBinding: binding, otherBindings: [CollectionBindingType]())
    }

    private func addBinding(_ binding: AnyBinding) {
        guard let other = binding as? CollectionBindingType else {
            preconditionFailure("Expected a binding of type \(CollectionBindingType.self), got \(type(of: binding))")
        }
        bindings.append(other)
    }

    func copy() -> AnyBinding {
        return CollectionBinding(collectionType: collectionType, firstBinding: firstBinding, otherBindings: bindings)
    }

    func createElement(provider: ProviderProtocol) -> Provider<CollectionType> {
        let firstProvider = firstBinding.createElement(provider: provider)
        let addedProviders = bindings.map { $0.createElement(provider: provider) }

        return Provider {
            addedProviders.reduce(self.collectionType.create(firstProvider.get()), { (result, p) in
                var newResult = result
                return newResult.mergeWith(p.get())
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
