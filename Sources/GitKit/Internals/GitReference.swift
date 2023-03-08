
protocol GitReference {
    init(pointer: GitPointer) throws
    var pointer: GitPointer { get }
}

extension GitReference {

    init(
        create: GitTask<Void, OpaquePointer>,
        configure: GitTask<OpaquePointer, Void>? = nil,
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

    func check(_ check: (OpaquePointer) -> Int32) -> Bool {
        check(pointer.pointer) != 0
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> UnsafePointer<Value> {
        guard let value = get(pointer.pointer) else { throw GitKitError.unexpectedNilValue }
        return value
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> Value {
        guard let value = get(pointer.pointer) else { throw GitKitError.unexpectedNilValue }
        return value.pointee
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