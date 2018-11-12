//
//  InjectorHelper.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public extension BinderProtocol where Element: InjectorProtocol {
    typealias InjectionHost = Element.Element
    
    func to<T1>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1) -> Void) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            
            return Provider {
                Element.init { host in
                    injector(host)(p1.get())
                }
            }
        }
    }
    
    func to<T1, T2>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2) -> Void) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            
            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get())
                }
            }
        }
    }
    
    func to<T1, T2, T3>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3) -> Void) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            
            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get())
                }
            }
        }
    }
    
    func to<T1, T2, T3, T4>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4) -> Void) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            let p4: Provider<T4> = c.provider()
            
            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get())
                }
            }
        }
    }
    
    func to<T1, T2, T3, T4, T5>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, injector: @escaping (InjectionHost) -> (T1, T2, T3, T4, T5) -> Void) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            let p4: Provider<T4> = c.provider()
            let p5: Provider<T5> = c.provider()
            
            return Provider {
                Element.init { host in
                    injector(host)(p1.get(), p2.get(), p3.get(), p4.get(), p5.get())
                }
            }
        }
    }
}
