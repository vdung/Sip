//
//  Validator.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

enum ValidationError: Error {
    case unsatisfiedDependency(_ type: Any.Type, requiredBy: AnyBinding)
    indirect case allErrors([ValidationError])
}

class Validator: ProviderProtocol {
    
    fileprivate let entries: [ContainerKey: AnyBinding]
    fileprivate var errors = [ValidationError]()
    fileprivate var bindingStack = [AnyBinding]()
    
    init(entries: [ContainerKey: AnyBinding]) {
        self.entries = entries
    }
    
    func provider<T>() -> T where T: AnyProvider {
        let key = unwrapKey(T.self)
        guard let binding = entries[key] else {
            errors.append(ValidationError.unsatisfiedDependency(key.type, requiredBy: bindingStack.last!))
            return T.init()
        }
        
        bindingStack.append(binding)
        defer {
            _ = bindingStack.popLast()
        }
        
        var provider = binding.createProvider(provider: self)
        provider = wrapProvider(provider, rawType: T.self)
        
        return provider.getAny() as! T
    }
    
    func validate<T>(_ type: T.Type, file: StaticString = #file, line: Int = #line, function: StaticString = #function) throws {
        bindingStack.append(Binding<Provider<T>>(file: file, line: line, function: function, bindingType: .unique) { _ in
            preconditionFailure("Should not ever be called")
        })
        defer {
            _ = bindingStack.popLast()
        }
        
        _ = provider() as Provider<T>
        
        if errors.count > 0 {
            throw ValidationError.allErrors(errors)
        }
    }
}
