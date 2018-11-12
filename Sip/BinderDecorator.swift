//
//  BinderDecorator.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

protocol BinderDecorator: BinderProtocol {
    associatedtype Wrapped: BinderProtocol
    associatedtype Element
    
    init(binder: Wrapped)
}

extension BinderProtocol {
    func decorate<B>() -> B where B : BinderDecorator, B.Wrapped == Self {
        return B.init(binder: self)
    }
}
