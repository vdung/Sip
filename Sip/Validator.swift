//
//  Validator.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

enum ValidationError: Error {
    case rootNotConfigured(component: Any.Type)
    case unsatisfiedDependency(_ type: Any.Type, requiredBy: AnyBinding)
    case cyclicDependency(cycle: [AnyBinding])
    indirect case multipleErrors([ValidationError])
}

private struct ProviderInfo {
    let binding: AnyBinding
    let resolvedType: Any.Type
}

class Validator: ProviderProtocol {

    fileprivate let container: Container
    fileprivate var bindingStack = [ProviderInfo]()
    private(set) var errors = [ValidationError]()

    init(container: Container) {
        self.container = container
    }

    func provider<T>() -> T where T: AnyProvider {
        let type = container.unwrapType(T.self)
        
        guard let binding = container.getBinding(forType: type) else {
            let error = ValidationError.unsatisfiedDependency(type, requiredBy: bindingStack.last!.binding)
            errors.append(error)
            
            return T(wrapped: ThrowingProvider {
                throw error
            })
        }
        
        if let index = bindingStack.lastIndex(where: { $0.resolvedType == T.element }) {
            let cycle = bindingStack.suffix(from: index).map { $0.binding } + [binding]
            let error = ValidationError.cyclicDependency(cycle: cycle)
            errors.append(error)
            
            return T(wrapped: ThrowingProvider {
                throw error
            })
        }

        return T.wrap {
            self.validate(binding: binding, resolvedType: T.element)
        }
    }

    @discardableResult
    func validate(binding: AnyBinding, resolvedType: Any.Type) -> AnyProvider {
        bindingStack.append(ProviderInfo(binding: binding, resolvedType: resolvedType))
        defer {
            bindingStack.removeLast()
        }
        
        return binding.createProvider(provider: self)
    }
}
