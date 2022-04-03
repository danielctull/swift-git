
// MARK: - FilePath

public struct FilePath: Equatable {
    let rawValue: String
}

extension FilePath: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension FilePath: CustomStringConvertible {
    public var description: String { rawValue }
}
