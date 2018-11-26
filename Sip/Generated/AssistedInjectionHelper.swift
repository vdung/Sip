//
//  AssistedInjectionHelper.swift
//  Sip
//
//  Generated by SipGen/main.swift on 2018/11/16.
//  DO NOT EDIT
//

public extension BinderProtocol where Element: AssistedInjectionFactoryProtocol {
    typealias Argument = Element.Argument
    typealias Output = Element.Element

    // 1-arity `to(elementFactory:)` function.
    public func to<T1>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), argument)
                }
            }
        })
    }

    // 2-arity `to(elementFactory:)` function.
    public func to<T1, T2>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), argument)
                }
            }
        })
    }

    // 3-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), argument)
                }
            }
        })
    }

    // 4-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), argument)
                }
            }
        })
    }

    // 5-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), argument)
                }
            }
        })
    }

    // 6-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5, T6>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, T6, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), argument)
                }
            }
        })
    }

    // 7-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, T6, T7, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), argument)
                }
            }
        })
    }

    // 8-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, T6, T7, T8, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()
            let p8: Provider<T8> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), argument)
                }
            }
        })
    }

    // 9-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, T6, T7, T8, T9, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()
            let p8: Provider<T8> = p.provider()
            let p9: Provider<T9> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), argument)
                }
            }
        })
    }

    // 10-arity `to(elementFactory:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, elementFactory: @escaping (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, Argument) -> Output) {
        to(file: file, line: line, function: function, creator: { p -> Provider<Element> in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()
            let p8: Provider<T8> = p.provider()
            let p9: Provider<T9> = p.provider()
            let p10: Provider<T10> = p.provider()

            return Provider {
                Element { argument in
                    elementFactory(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), argument)
                }
            }
        })
    }
}
