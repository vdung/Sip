//
//  Module.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol Module {

    func configure(binder: BinderDelegate)
}

extension BinderDelegate {
    func include(_ module: Module) {
        module.configure(binder: self)
    }
}
