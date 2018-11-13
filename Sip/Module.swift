//
//  Module.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol Module {
    
    func register(binder: BinderDelegate)
}

extension BinderDelegate {
    func include(_ module: Module) {
        module.register(binder: self)
    }
}
