
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

    func get<Value>(
        _ get: (UnsafeMutablePointer<Value?>?, OpaquePointer?) -> Int32
    ) throws -> Value {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value) { get($0, pointer.pointer) }
        if let error = LibGit2Error(result) { throw error }
        guard let unwrapped = value else { throw GitKitError.unexpectedNilValue }
        return unwrapped
    }
}

extension GitReference {

    func create(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32
    ) -> GitPointer.Create {
        { create($0, pointer.pointer) }
    }

    func create<A>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitPointer.Create {
        { create($0, pointer.pointer, a) }
    }

    func create<A, B>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitPointer.Create {
        { create($0, pointer.pointer, a, b) }
    }

    func create<A, B, C>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitPointer.Create {
        { create($0, pointer.pointer, a, b, c) }
    }
}
