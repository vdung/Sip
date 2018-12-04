//
//  Module.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol ModuleBinder: BinderDelegate {}

public protocol Module {

    func configure(binder: ModuleBinder)
}

extension ModuleBinder {
    func include(_ module: Module) {
        module.configure(binder: self)
    }
}
