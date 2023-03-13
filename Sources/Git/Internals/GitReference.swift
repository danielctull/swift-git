
protocol GitReference {
    init(pointer: GitPointer) throws
    var pointer: GitPointer { get }
}

extension GitReference {

    init(
        create: GitPointer.Create,
        configure: GitPointer.Configure? = nil,
        free: @escaping GitPointer.Free
    ) throws {
        try self.init(
            pointer: GitPointer(
                create: create,
                configure: configure,
                free: free)
        )
    }
}

extension GitReference {

    func get<CType, Value>(
        _ task: @escaping (OpaquePointer) -> CType,
        as conversion: (CType) throws -> Value
    ) throws -> Value {
        try pointer.get(task) |> conversion
    }

    func get<A, CType, Value>(
        _ task: @escaping (OpaquePointer, A) -> CType,
        _ a: A,
        as conversion: (CType) throws -> Value
    ) throws -> Value {
        try pointer.get(task, a) |> conversion
    }
}
