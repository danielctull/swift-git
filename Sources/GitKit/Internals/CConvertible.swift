
protocol CConvertible {
    associatedtype CType
    init(convert: CType) throws
}

extension GitPointer {

    func get<Value: CConvertible>(
        _ task: @escaping (OpaquePointer) -> Value.CType,
        as value: Value.Type
    ) throws -> Value {
        let task = GitTask { task(self.pointer) }
        return try Value(convert: task())
    }
}

// MARK: - Implementations

extension String: CConvertible {

    init(convert: UnsafePointer<CChar>?) throws {
        try self.init(convert)
    }
}
