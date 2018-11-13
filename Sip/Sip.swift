//
//  Sip.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

func builder<T: Component>(_ componentType: T.Type) throws -> ComponentBuilder<T> {
    return try ComponentBuilder.of(componentType)
}
