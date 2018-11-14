import Sip

protocol Pump {
    func pump()
}

protocol Heater {
    func on()
    func off()
    var isHot: Bool { get }
}

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
    func register(binder b: BinderDelegate) {
        b.bind(Pump.self).to(factory: Thermosiphon.init)
    }
}

struct DripCoffeeModule: Module {
    func register(binder b: BinderDelegate) {
        b.bind(Heater.self).sharedInScope().to(factory: ElectricHeater.init)
    }
}

struct CoffeShop: Component {
    typealias Root = Injector<CoffeeMaker>

    static func configureRoot<B>(binder: B) where B: BinderProtocol, CoffeShop.Root == B.Element {
        return binder.to(injector: CoffeeMaker.inject)
    }

    static func configure<Builder>(builder: Builder) where CoffeShop == Builder.ComponentElement, Builder: ComponentBuilderProtocol {
        builder.include(PumpModule())
        builder.include(DripCoffeeModule())
    }
}

let coffeeMaker = CoffeeMaker()
ComponentBuilders.of(CoffeShop.self).build().inject(coffeeMaker)
coffeeMaker.brew()

//: [Next](@next)
