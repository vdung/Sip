//
//  CollectionBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol CollectionBindingResult {
    associatedtype Element
    static func create(_ element: Element) -> Self
    func mergeWith(_ other: Self) -> Self
}

extension Array: CollectionBindingResult {
    public static func create(_ element: Element) -> Array<Element> {
        return [element]
    }
    
    public func mergeWith(_ other: Array<Element>) -> Array<Element> {
        var result = self
        result.append(contentsOf: other)
        return result
    }
}

extension Dictionary: CollectionBindingResult {
    public static func create(_ element: (key: Key, value: Value)) -> Dictionary<Key, Value> {
        return Dictionary(dictionaryLiteral: element)
    }
    
    public func mergeWith(_ other: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var result = self
        result.merge(other) { (value1, value2) -> Value in
            preconditionFailure("Duplicate keys for different binding: \(value1), \(value2)")
        }
        return result
    }
}

public class CollectionBinder<B>: BinderDecorator where B: BinderProtocol, B.Element: CollectionBindingResult  {
    public typealias Wrapped = B
    public typealias CollectionType = B.Element
    public typealias Element = CollectionType.Element
    
    private let binder: B
    private var bindings = [Binding<Provider<CollectionType>>]()
    
    required init(binder: B) {
        self.binder = binder
    }
    
    private func addBinding(_ binding: AnyBinding) {
        guard let other = binding as? Binding<Provider<B.Element>> else {
            preconditionFailure("Expected a binding of type \(Binding<Provider<CollectionType>>.self), got \(type(of: binding))")
        }
        bindings.append(other)
    }
    
    public func to(binding: Binding<Provider<Element>>) {
        binder.to(binding: Binding(file: binding.file, line: binding.line, function: binding.function, bindingType: .collection({ [unowned self] in self.addBinding($0)
        }), create: { c in
            let firstProvider = binding.create(c)
            let addedProviders = self.bindings.map { $0.create(c) }
            return Provider<CollectionType> {
                addedProviders.reduce(CollectionType.create(firstProvider.get()), { (result, provider) in
                    result.mergeWith(provider.get())
                })
            }
        }))
    }
}

extension BinderProtocol where Element: CollectionBindingResult {
    public func intoCollection() -> CollectionBinder<Self> {
        return decorate()
    }
}

extension BinderProtocol {
    
    public func mapKey<Key, Value>(_ key: Key) -> Binder<Value> where Element == (key: Key, value: Value) {
        return Binder(elementType: Value.self, bindFunc: { (binding) in
            self.to(binding: binding.convert { create in
                { p in
                    create(p).to { value in (key, value) }
                }
            })
        })
    }
}

public extension Container {
    
    public func bindIntoCollectionOf<T>(_ type: T.Type) -> CollectionBinder<Binder<[T]>> {
        return Binder(elementType: [T].self, bindFunc: self.register)
            .decorate()
    }
    
    public func bindIntoMapOf<Key: Hashable, T>(_ type: T.Type) -> CollectionBinder<Binder<[Key: T]>> {
        return Binder(elementType: [Key: T].self, bindFunc: self.register)
            .decorate()
    }
}
