
struct GitKitError: Error, CustomStringConvertible {

    let description: String
    private init(_ description: String) {
        self.description = description
    }
}

extension GitKitError {

    static func unexpectedValue(expected: [String], received: String) -> GitKitError {
        .unexpectedValue(expected: expected.joined(separator: ", "), received: received)
    }

    static func unexpectedValue(expected: String, received: String) -> GitKitError {
        GitKitError("Expected: \(expected). Received \(received)")
    }
}
