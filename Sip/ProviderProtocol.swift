//
//  ProviderProtocol.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public protocol ProviderProtocol {
    func provider<T>() -> T where T: AnyProvider
}
