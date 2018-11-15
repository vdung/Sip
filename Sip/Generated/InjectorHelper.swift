//
//  InjectorHelper.swift
//  Sip
//
//  Generated by SipGen/main.swift on 2018/11/15.
//  DO NOT EDIT
//

public extension BinderProtocol where Element: InjectorProtocol {
    typealias InjectionHost = Element.Element

    // 1-arity `to(injector:)` function.
    public func to<T1>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get())
                }
            }
        }
    }

    // 2-arity `to(injector:)` function.
    public func to<T1, T2>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get())
                }
            }
        }
    }

    // 3-arity `to(injector:)` function.
    public func to<T1, T2, T3>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get())
                }
            }
        }
    }

    // 4-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get())
                }
            }
        }
    }

    // 5-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get())
                }
            }
        }
    }

    // 6-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5, T6>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5, T6) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get())
                }
            }
        }
    }

    // 7-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5, T6, T7) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get())
                }
            }
        }
    }

    // 8-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5, T6, T7, T8) -> Void) {
        return to(file: file, line: line, function: function) { p in
            let p1: Provider<T1> = p.provider()
            let p2: Provider<T2> = p.provider()
            let p3: Provider<T3> = p.provider()
            let p4: Provider<T4> = p.provider()
            let p5: Provider<T5> = p.provider()
            let p6: Provider<T6> = p.provider()
            let p7: Provider<T7> = p.provider()
            let p8: Provider<T8> = p.provider()

            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get())
                }
            }
        }
    }

    // 9-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5, T6, T7, T8, T9) -> Void) {
        return to(file: file, line: line, function: function) { p in
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
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get())
                }
            }
        }
    }

    // 10-arity `to(injector:)` function.
    public func to<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) -> Void) {
        return to(file: file, line: line, function: function) { p in
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
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get())
                }
            }
        }
    }
}