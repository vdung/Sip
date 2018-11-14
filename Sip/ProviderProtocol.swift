//
//  ProviderProtocol.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

public protocol ProviderProtocol {
    func provider<T>() -> T where T: AnyProvider
}
