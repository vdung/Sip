//
//  Validator.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

enum ValidationError: Error {
    case unsatisfiedDependency(_ type: Any.Type, requiredBy: AnyBinding)
    indirect case allErrors([ValidationError])
}

class Validator: ProviderProtocol {

    fileprivate let container: Container
    fileprivate var errors = [ValidationError]()
    fileprivate var bindingStack = [AnyBinding]()

    init(container: Container) {
        self.container = container
    }

    func provider<T>() -> T where T: AnyProvider {
        let type = container.unwrapType(T.self)
        
        guard let binding = container.getBinding(forType: type) else {
            let error = ValidationError.unsatisfiedDependency(type, requiredBy: bindingStack.last!)
            errors.append(error)
            
            return T(wrapped: ThrowingProvider {
                throw error
            })
        }

        bindingStack.append(binding)
        defer {
            bindingStack.removeLast()
        }

        let provider = binding.createProvider(provider: self)

        return provider.wrap()
    }

    func validate<B>(binding: B) where B: BindingBase, B.Element: ProviderBase {
        bindingStack.append(binding)
        defer {
            bindingStack.removeLast()
        }

        _ = provider() as B.Element
    }
}

class ValidationBinder<Element>: BinderProtocol {
    private let elementType: Element.Type
    private let container: Container
    private(set) var errors = [ValidationError]()
    
    init(elementType: Element.Type, container: Container) {
        self.elementType = elementType
        self.container = container
    }
    
    public func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase, B.Element.Element == Element {
        container.register(binding: binding)
        
        let validator = Validator(container: container)
        validator.validate(binding: binding)
        errors.append(contentsOf: validator.errors)
    }
}
