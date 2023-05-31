
// MARK: - LineNumber

public struct LineNumber: Equatable, Sendable {
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

extension LineNumber: CustomStringConvertible {

    public var description: String { String(rawValue) }
}

extension ClosedRange where Bound == LineNumber {

    init<I: BinaryInteger>(start: I, count: I) {
        let start = LineNumber(Int(start))
        let end = start.advanced(by: Int(count) - 1)
        self.init(uncheckedBounds: (start, end))
    }
}

extension ClosedRange {

    var shortDescription: String { "\(lowerBound)...\(upperBound)" }
}
