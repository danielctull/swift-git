
struct GitKitError: Error, CustomStringConvertible {

    let description: String
    private init(_ description: String) {
        self.description = description
    }
}

extension GitKitError {

    static func incorrectType(expected: String) -> GitKitError {
        GitKitError("Incorrect Type. Expected: \(expected).")
    }
}
