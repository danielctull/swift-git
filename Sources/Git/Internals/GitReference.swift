
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

extension GitReference {

    func check(_ check: (OpaquePointer) -> Int32) -> Bool {
        check(pointer.pointer) != 0
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> UnsafePointer<Value> {
        try Unwrap(get(pointer.pointer))
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> Value {
        try Unwrap(get(pointer.pointer)).pointee
    }

    func get(
        _ get: (OpaquePointer?) -> OpaquePointer?
    ) throws -> GitPointer {
        GitPointer(try Unwrap(get(pointer.pointer)))
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> Value
    ) -> Value {
        get(pointer.pointer)
    }
}
