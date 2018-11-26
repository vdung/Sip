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

        case .boundMultipleTimes(let rawType, bindings: let bindings):
            return """
            Type \(rawType) is bound multiple times:
            \(bindings.map({ "\($0)\n" }).joined())
            """

        case .cyclicDependency(cycle: let bindings):
            return """
            Circular dependency detected:
            \(bindings.map({ "\($0)\n" }).joined())
            """

        case .multipleErrors(let errors):
            return """
            Multiple errors detected:
            \(errors.map({ "\n\($0)" }).joined())
            """
        }
    }
}

extension ProviderInfo {

    func validate(bindingStack: [ResolveInfo], errors: inout [ValidationError]) {
        for d in dependencies {
            component.validate(resolvedType: d, bindingStack: bindingStack, errors: &errors)
        }
    }
}

extension ComponentInfo {

    func validate() throws {
        var errors = [ValidationError]()
        validate(resolvedType: rootType, bindingStack: [], errors: &errors)

        if errors.count == 1 {
            throw errors[0]
        }
        if errors.count > 1 {
            throw ValidationError.multipleErrors(errors)
        }
    }

    func validate(resolvedType: AnyProvider.Type, bindingStack: [ResolveInfo], errors: inout [ValidationError]) {
        let rawType = resolvedType.unwrap()
        let providerInfos = getAllProviderInfos(forType: rawType)

        if providerInfos.count == 0 {
            errors.append(ValidationError.unsatisfiedDependency(rawType, requiredBy: bindingStack.map { $0.binding }))

            return
        }

        if let index = bindingStack.lastIndex(where: { $0.providerType.unwrap() == rawType }) {
            if bindingStack.suffix(from: index)
                .filter({ $0.providerType.element != $0.providerType.unwrap() })
                .count == 0 {
                let cycle = bindingStack.suffix(from: index).map { $0.binding } + [providerInfos[0].binding]
                errors.append(ValidationError.cyclicDependency(cycle: cycle))
            }

            return
        }

        let uniqueBindingCount = providerInfos.filter {
            !$0.binding.isMultiBinding()
            }.count

        if providerInfos.count > 1 && uniqueBindingCount > 0 {
            errors.append(ValidationError.boundMultipleTimes(
                resolvedType,
                bindings: providerInfos.map { $0.binding }
            ))
        }

        for p in providerInfos {
            p.validate(bindingStack: bindingStack + [
                ResolveInfo(providerType: resolvedType, binding: p.binding)
                ], errors: &errors)
        }
    }
}
