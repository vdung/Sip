//
//  Binding.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public enum BindingType {
    case unique
    case collection((AnyProvider) -> AnyBinding)
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

extension AnyBinding {

    func isMultiBinding() -> Bool {
        switch bindingType {
        case .collection:
            return true
        default:
            return false
        }
    }

    func acceptProvider(_ provider: AnyProvider) -> AnyBinding {
        switch bindingType {
        case .unique:
            preconditionFailure("Type \(type(of: provider).element) is already bound to unique binding")
        case .collection(let merge):
            return merge(provider)
        }
    }
}

public protocol BindingBase: AnyBinding, CustomStringConvertible {
    associatedtype Element
    init(copy: Self)
    func createElement(provider: ProviderProtocol) -> Element
}

extension BindingBase where Element: AnyProvider {
    public func createProvider(provider: ProviderProtocol) -> AnyProvider {
        return createElement(provider: provider)
    }

    public func copy() -> AnyBinding {
        return Self.init(copy: self)
    }
}

extension BindingBase {
    public var element: Any.Type { return Element.self }
}

extension BindingBase where Element: AnyProvider {
    public var description: String {
        return "Binding for \(Element.element) in file \(file) line \(line)"
    }
}

protocol DelegatedBinding {
    var delegate: AnyBinding { get }
}

extension DelegatedBinding where Self: AnyBinding {
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

extension Binding: AnyBinding, BindingBase, CustomStringConvertible where Element: AnyProvider {

    public init(copy: Binding<Element>) {
        self.init(file: copy.file, line: copy.line, function: copy.function, bindingType: copy.bindingType, create: copy.create)
    }

    public func createElement(provider: ProviderProtocol) -> Element {
        return create(provider)
    }

    public func createProvider(provider: ProviderProtocol) -> AnyProvider {
        return createElement(provider: provider)
    }
}
