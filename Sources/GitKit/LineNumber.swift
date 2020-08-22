
public struct LineNumber: Equatable {
    let rawValue: Int
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension LineNumber: Comparable {
    public static func < (lhs: LineNumber, rhs: LineNumber) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension LineNumber: Strideable {

    public func distance(to other: LineNumber) -> Int {
        rawValue.distance(to: other.rawValue)
    }

    public func advanced(by amount: Int) -> LineNumber {
        LineNumber(rawValue.advanced(by: amount))
    }
}

extension LineNumber: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}
