
// MARK: - Create a String from a GitTask

extension String {

    init(_ cchar: UnsafePointer<CChar>) throws {
        self = try Unwrap(String(validatingUTF8: cchar))
    }

    init(_ cchar: UnsafePointer<CChar>?) throws {
        try self.init(Unwrap(cchar))
    }

    init(_ task: GitTask<Void, UnsafePointer<CChar>>) throws {
        try self.init(task())
    }

    init(_ task: GitTask<Void, UnsafePointer<CChar>?>) throws {
        try self.init(task())
    }
}
