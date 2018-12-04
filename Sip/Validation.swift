//
//  Validation.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/21.
//

enum ValidationError: Error {

    case unsatisfiedDependency(_ type: Any.Type, requiredBy: [AnyBinding])
    case boundMultipleTimes(_ type: Any.Type, bindings: [AnyBinding])
    case cyclicDependency(cycle: [AnyBinding])
    case conflictingScopes(componentScope: [Scope.Type], binding: AnyBinding)
    indirect case multipleErrors([ValidationError])
}

extension ValidationError: CustomStringConvertible {

    var description: String {
        switch self {
        case .unsatisfiedDependency(let rawType, requiredBy: let bindingStack):
            return """
            Cannot find binding for \(rawType), required by:
            \(bindingStack.reversed().enumerated().map({ (offset, binding) in
            "\(String(repeating: " ", count: offset))\(binding)\n"
            }).joined())
            """

        case .boundMultipleTimes(let rawType, let bindings):
            return """
            Type \(rawType) is bound multiple times:
            \(bindings.map({ "\($0)\n" }).joined())
            """

        case .cyclicDependency(let bindings):
            return """
            Circular dependency detected:
            \(bindings.map({ "\($0)\n" }).joined())
            """
            
        case .conflictingScopes(let componentScope, let binding):
            return """
            Component scoped with \(componentScope) may not reference binding with different scope:
            \(binding)
            """

        case .multipleErrors(let errors):
            return """
            Multiple errors detected:
            \(errors.map({ "\n\($0)" }).joined())
            """
        }
    }
}
