
extension String {

    init(_ cchar: UnsafePointer<CChar>?) throws {
        self = try Unwrap(String(validatingUTF8: Unwrap(cchar)))
    }
}
