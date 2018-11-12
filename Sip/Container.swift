//
//  Container.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

// MARK: Container

public protocol Container: ProviderProtocol {
    
    func register<B>(binding: B) where B: BindingBase, B.Element: ProviderBase
}
