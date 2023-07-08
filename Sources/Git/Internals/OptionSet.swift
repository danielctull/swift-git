
// MARK: - Option

/// This is used to supply internal options.
///
/// It's undesirable for external users to create options using raw integer
/// values, so this type exists to allow the external representation required by
/// ``OptionSet``, but without the ability for external users to create one.
public struct Option: Equatable, Sendable {
    fileprivate let rawValue: UInt32
}

extension OptionSet where RawValue == Option {

    public init() {
        self = Self(rawValue: Option(rawValue: 0))
    }

    public mutating func formUnion(_ other: Self) {
        self = Self(rawValue: Option(rawValue: rawValue.rawValue | other.rawValue.rawValue))
    }

    public mutating func formIntersection(_ other: Self) {
        self = Self(rawValue: Option(rawValue: rawValue.rawValue & other.rawValue.rawValue))
    }

    public mutating func formSymmetricDifference(_ other: Self) {
        self = Self(rawValue: Option(rawValue: rawValue.rawValue ^ other.rawValue.rawValue))
    }
}

extension OptionSet where RawValue == Option {

    func withRawValue(_ f: (UInt32) throws -> ()) rethrows {
        try f(rawValue.rawValue)
    }
}

// MARK: - GitOptionSet

protocol GitOptionSet: OptionSet {
    associatedtype OptionType: RawRepresentable where OptionType.RawValue == UInt32
}

extension GitOptionSet where RawValue == Option {

    init(rawValue: UInt32) {
        self.init(rawValue: Option(rawValue: rawValue))
    }

    init(_ value: OptionType) {
        self.init(rawValue: Option(rawValue: value.rawValue))
    }
}
