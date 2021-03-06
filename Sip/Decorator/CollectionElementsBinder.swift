//
//  CollectionElementsBinder.swift
//  Sip
//
//  Created by Cao Viet Dung on 2018/11/22.
//

private class CollectionElementsBinding<UnderlyingBinding>: DelegatedBinding, CollectionBindingBase where UnderlyingBinding: BindingBase, UnderlyingBinding.Element: ProviderBase, UnderlyingBinding.Element.Element: CollectionBindingResult {
    typealias CollectionType = UnderlyingBinding.Element.Element
    typealias Element = ThrowingProvider<CollectionType>

    private let firstBinding: UnderlyingBinding
    var providers: [Element]

    var delegate: AnyBinding {
        return firstBinding
    }

    var bindingType: BindingType {
        return BindingType.collection({ [unowned self] in
            self.appendProvider($0)
        })
    }

    required convenience init(copy: CollectionElementsBinding<UnderlyingBinding>) {
        self.init(firstBinding: UnderlyingBinding(copy: copy.firstBinding), providers: copy.providers)
    }

    convenience init(binding: UnderlyingBinding) {
        self.init(firstBinding: binding, providers: [Element]())
    }

    init(firstBinding: UnderlyingBinding, providers: [Element]) {
        self.firstBinding = firstBinding
        self.providers = providers
    }

    func initialElementProvider(provider: ProviderProtocol) -> ThrowingProvider<CollectionType> {
        let firstProvider = firstBinding.createElement(provider: provider)
        return ThrowingProvider {
            try firstProvider.get()
        }
    }
}

public class CollectionElementsBinder<Wrapped>: BinderDecorator where Wrapped: BinderProtocol, Wrapped.Element: CollectionBindingResult {
    public typealias Element = Wrapped.Element

    private let binder: Wrapped

    required init(binder: Wrapped) {
        self.binder = binder
    }

    public func register<B>(binding: B) where B: BindingBase, CollectionElementsBinder<Wrapped>.Element == B.Element.Element, B.Element: ProviderBase {
        binder.register(binding: CollectionElementsBinding(binding: binding))
    }
}

extension BinderProtocol where Element: CollectionBindingResult {
    public func elementsIntoCollection() -> CollectionElementsBinder<Self> {
        return decorate()
    }
}
