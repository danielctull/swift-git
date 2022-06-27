
// MARK: - Create a String from a GitTask

extension String {

    init(_ task: GitTask<Void, UnsafePointer<CChar>>) throws {
        self = try Unwrap(String(validatingUTF8: task()))
    }
}
