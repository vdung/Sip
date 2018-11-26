//
//  CollectionBinding.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/22.
//

public protocol CollectionBindingResult {
    associatedtype Element
    init(elements: Element...)
    mutating func merge(_ other: Self)
}

protocol CollectionBindingBase: class, BindingBase where Element: ProviderBase, Element.Element: CollectionBindingResult {
    typealias CollectionType = Element.Element
    var bindings: [AnyBinding] { get set }
    
    func initialElementProvider(provider: ProviderProtocol) -> Element
}

extension CollectionBindingBase {
    
    func addBinding(_ binding: AnyBinding) {
        guard let providerType = binding.element as? AnyProvider.Type else {
            preconditionFailure("Expected a binding of a provider, got \(binding)")
        }
        if providerType.element != Element.Element.self {
            preconditionFailure("Expected a binding for \(Element.Element.self), got \(binding)")
        }
        
        bindings.append(binding)
    }
    
    func createElement(provider: ProviderProtocol) -> Element {
        let firstProvider = initialElementProvider(provider: provider)
        let addedProviders = bindings.map { Element(wrapped: $0.createProvider(provider: provider)) }
        
        return Element(wrapped: ThrowingProvider {
            try addedProviders.reduce(into: firstProvider.get(), { (result: inout CollectionType, p) in
                result.merge(try p.get())
            })
        })
    }
}

extension Array: CollectionBindingResult {
    public init(elements: Element...) {
        self.init(elements)
    }
    
    public mutating func merge(_ other: Array<Element>) {
        self.append(contentsOf: other)
    }
}

extension Dictionary: CollectionBindingResult {
    public init(elements: Element...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
    public mutating func merge(_ other: Dictionary<Key, Value>) {
        self.merge(other) { (value1, value2) -> Value in
            preconditionFailure("Duplicate keys for different binding: \(value1), \(value2)")
        }
    }
}
