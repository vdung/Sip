//
//  Binding.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public enum BindingType {
    case unique
    case collection((AnyBinding) -> Void)
    
    func acceptBinding(_ binding: AnyBinding) {
        switch self {
        case .unique:
            preconditionFailure("Type \(binding.element) is already bound to unique binding")
        case .collection(let merge):
            merge(binding)
        }
    }
}

public protocol AnyBinding {
    var file: StaticString { get }
    var line: Int { get }
    var function: StaticString { get }
    var element: Any.Type { get }
    var bindingType: BindingType { get set }
    
    func createProvider(provider: ProviderProtocol) -> AnyProvider
}

typealias CreatorFunc<T> = (ProviderProtocol) -> T

public protocol BindingBase: AnyBinding {
    associatedtype Element
}

extension BindingBase {
    public var element: Any.Type { return Element.self }
}

public struct Binding<Element> {
    public let file: StaticString
    public let line: Int
    public let function: StaticString
    public var bindingType: BindingType = BindingType.unique
    let create: CreatorFunc<Element>
}

extension Binding {
    func convert<U>(converter: (@escaping CreatorFunc<Element>) -> CreatorFunc<U>) -> Binding<U> {
        return Binding<U>(file: file, line: line, function: function, bindingType: bindingType, create: converter(create))
    }
}

extension Binding: CustomStringConvertible {
    public var description: String {
        return "type \(Element.self) in file \(file) line \(line)"
    }
}

extension Binding: AnyBinding, BindingBase where Element: AnyProvider {
    public func createProvider(provider: ProviderProtocol) -> AnyProvider {
        return self.create(provider)
    }
}
