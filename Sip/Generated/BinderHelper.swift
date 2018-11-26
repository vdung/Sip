//
//  BinderHelper.swift
//  Sip
//
//  Generated by SipGen/main.swift on 2018/11/16.
//  DO NOT EDIT
//

public extension BinderProtocol {

    // 1-arity `to(factory:)` function.
    public func to<T1>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get()))
            }
        })
    }

    // 2-arity `to(factory:)` function.
    public func to<T1, T2>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get()))
            }
        })
    }

    // 3-arity `to(factory:)` function.
    public func to<T1, T2, T3>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get()))
            }
        })
    }

    // 4-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get()))
            }
        })
    }

    // 5-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get()))
            }
        })
    }

    // 6-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5, T6>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5, T6)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()
            let p6: ThrowingProvider<T6> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get(), try p6.get()))
            }
        })
    }

    // 7-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5, T6, T7)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()
            let p6: ThrowingProvider<T6> = p.provider()
            let p7: ThrowingProvider<T7> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get(), try p6.get(), try p7.get()))
            }
        })
    }

    // 8-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5, T6, T7, T8)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()
            let p6: ThrowingProvider<T6> = p.provider()
            let p7: ThrowingProvider<T7> = p.provider()
            let p8: ThrowingProvider<T8> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get(), try p6.get(), try p7.get(), try p8.get()))
            }
        })
    }

    // 9-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5, T6, T7, T8, T9)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()
            let p6: ThrowingProvider<T6> = p.provider()
            let p7: ThrowingProvider<T7> = p.provider()
            let p8: ThrowingProvider<T8> = p.provider()
            let p9: ThrowingProvider<T9> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get(), try p6.get(), try p7.get(), try p8.get(), try p9.get()))
            }
        })
    }

    // 10-arity `to(factory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)) throws -> Element) {
        to(file: file, line: line, function: function, creator: { p -> ThrowingProvider<Element> in
            let p1: ThrowingProvider<T1> = p.provider()
            let p2: ThrowingProvider<T2> = p.provider()
            let p3: ThrowingProvider<T3> = p.provider()
            let p4: ThrowingProvider<T4> = p.provider()
            let p5: ThrowingProvider<T5> = p.provider()
            let p6: ThrowingProvider<T6> = p.provider()
            let p7: ThrowingProvider<T7> = p.provider()
            let p8: ThrowingProvider<T8> = p.provider()
            let p9: ThrowingProvider<T9> = p.provider()
            let p10: ThrowingProvider<T10> = p.provider()

            return ThrowingProvider {
                try factory((try p1.get(), try p2.get(), try p3.get(), try p4.get(), try p5.get(), try p6.get(), try p7.get(), try p8.get(), try p9.get(), try p10.get()))
            }
        })
    }
}
