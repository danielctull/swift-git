
struct GitKitError: Error, CustomStringConvertible {

    let description: String
    private init(_ description: String) {
        self.description = description
    }
}

extension GitKitError {

    static func incorrectType(expected: String) -> GitKitError {
        GitKitError("Incorrect type. Expected: \(expected).")
    }

    static var unexpectedNilValue: GitKitError {
        GitKitError("Unexpted nil value.")
    }
}
