//
//  BinderHelper.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public extension BinderProtocol {

    
    public func to<T1>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1)) -> Element) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            
            return Provider {
                factory((p1.get()))
            }
        }
    }
    
    
    public func to<T1, T2>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2)) -> Element) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            
            return Provider {
                factory((p1.get(), p2.get()))
            }
        }
    }
    
    
    public func to<T1, T2, T3>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3)) -> Element) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            
            return Provider {
                factory((p1.get(), p2.get(), p3.get()))
            }
        }
    }
    
    
    public func to<T1, T2, T3, T4>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4)) -> Element) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            let p4: Provider<T4> = c.provider()
            
            return Provider {
                factory((p1.get(), p2.get(), p3.get(), p4.get()))
            }
        }
    }
    
    
    public func to<T1, T2, T3, T4, T5>(file: StaticString=#file, line: Int=#line, function: StaticString=#function, factory: @escaping ((T1, T2, T3, T4, T5)) -> Element) -> Void {
        return to(file: file, line: line, function: function) { c in
            let p1: Provider<T1> = c.provider()
            let p2: Provider<T2> = c.provider()
            let p3: Provider<T3> = c.provider()
            let p4: Provider<T4> = c.provider()
            let p5: Provider<T5> = c.provider()
            
            return Provider {
                factory((p1.get(), p2.get(), p3.get(), p4.get(), p5.get()))
            }
        }
    }
}
