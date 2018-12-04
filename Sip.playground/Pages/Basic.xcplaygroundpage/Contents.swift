import Sip

protocol Pump {
    func pump()
}

protocol Heater {
    func on()
    func off()
    var isHot: Bool { get }
}

struct CoffeShopScoped: Scope {}

class Thermosiphon: Pump {
    let heater: Heater

    init(heater: Heater) {
        self.heater = heater
    }

    func pump() {
        if heater.isHot {
            print("=> => pumping => =>")
        }
    }
}

class ElectricHeater: Heater {
    private var heating = false

    var isHot: Bool {
        return heating
    }

    func on() {
        print("~ ~ ~ Heating ~ ~ ~")
        heating = true
    }

    func off() {
        heating = false
    }
}

class CoffeeMaker {
    var heater: Provider<Heater>! // Create a possibly costly heater only when we use it.
    var pump: Pump!

    func inject(heater: Provider<Heater>, pump: Pump) {
        self.heater = heater
        self.pump = pump
    }

    func brew() {
        heater.get().on()
        pump.pump()
        print(" [_]P coffee! [_]P ")
        heater.get().off()
    }
}

struct PumpModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(Pump.self).to(factory: Thermosiphon.init)
    }
}

struct DripCoffeeModule: Module {
    func configure(binder b: ModuleBinder) {
        b.bind(Heater.self)
            .inScope(CoffeShopScoped.self)
            .to(factory: ElectricHeater.init)
    }
}

struct CoffeShop: Component {
    typealias Root = Injector<CoffeeMaker>

    static func configureRoot<B>(binder: B) where B: BinderProtocol, CoffeShop.Root == B.Element {
        return binder.to(injector: CoffeeMaker.inject)
    }

    static func configure<Builder>(builder: Builder) where Builder: ComponentBuilderProtocol {
        builder.include(PumpModule())
        builder.include(DripCoffeeModule())
        builder.scope(CoffeShopScoped.self)
    }
}

let coffeeMaker = CoffeeMaker()
CoffeShop.builder().build().inject(coffeeMaker)
coffeeMaker.brew()

//: [Next](@next)
