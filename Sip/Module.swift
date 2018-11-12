//
//  Module.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol Module {
    
    func register(container: Container)
}

extension Container {
    func include(_ module: Module) {
        module.register(container: self)
    }
}
