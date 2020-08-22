
public struct FilePath: Equatable {
    let rawValue: String
}

extension FilePath: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
