//
//  Binding.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

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
    var bindingType: BindingType { get }

    func copy() -> AnyBinding
    func createProvider(provider: ProviderProtocol) -> AnyProvider
}

public protocol BindingBase: AnyBinding, CustomStringConvertible {
    associatedtype Element

    func createElement(provider: ProviderProtocol) -> Element
}

extension BindingBase where Element: AnyProvider {
    public func createProvider(provider: ProviderProtocol) -> AnyProvider {
        return createElement(provider: provider)
    }
}

extension BindingBase {
    public var element: Any.Type { return Element.self }
}

protocol DelegatedBinding {
    var delegate: AnyBinding { get }
}

extension DelegatedBinding where Self: BindingBase {
    var file: StaticString { return delegate.file }
    var line: Int { return delegate.line }
    var function: StaticString { return delegate.function }
    var bindingType: BindingType { return delegate.bindingType }
}

public typealias CreatorFunc<T> = (ProviderProtocol) -> T

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

extension AnyBinding {
    public var description: String {
        return "type \(element) in file \(file) line \(line)"
    }
}

extension Binding: AnyBinding, BindingBase, CustomStringConvertible where Element: AnyProvider {
    public func copy() -> AnyBinding {
        return Binding(file: file, line: line, function: function, bindingType: bindingType, create: create)
    }

    public func createElement(provider: ProviderProtocol) -> Element {
        return create(provider)
    }

    public func createProvider(provider: ProviderProtocol) -> AnyProvider {
        return createElement(provider: provider)
    }
}
