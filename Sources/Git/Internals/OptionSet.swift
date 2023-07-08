
protocol GitOptionSet: OptionSet {
    associatedtype OptionType: RawRepresentable where OptionType.RawValue == UInt32
}

extension GitOptionSet where RawValue == UInt32 {

    init(_ value: OptionType) {
        self.init(rawValue: value.rawValue)
    }
}
