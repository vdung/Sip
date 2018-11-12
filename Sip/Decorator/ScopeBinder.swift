//
//  ScopeBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/12.
//

import Foundation

public class SharedInScopeBinder<B>: BinderDecorator where B: BinderProtocol {
    public typealias Element = B.Element
    typealias Wrapped = B
    
    private let binder: B
    private var value: Element?
    
    required init(binder: B) {
        self.binder = binder
    }
    
    public func to(binding: Binding<Provider<Element>>) {
        binder.to(binding: binding.convert {
            create in {
                p in
                Provider<Element> {
                    if let value = self.value {
                        return value
                    }
                    
                    let provider = create(p)
                    self.value = provider.get()
                    return self.value!
                }
            }
        })
    }
}

public extension BinderProtocol {
    func sharedInScope() -> SharedInScopeBinder<Self> {
        return decorate()
    }
}
