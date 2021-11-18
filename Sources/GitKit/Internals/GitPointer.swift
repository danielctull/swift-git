
import Clibgit2

final class GitPointer {

    typealias Create = (UnsafeMutablePointer<OpaquePointer?>) -> Int32
    typealias Configure = (OpaquePointer) -> Int32
    typealias Free = (OpaquePointer) -> Void

    let pointer: OpaquePointer
    private let free: Free

    deinit { free(pointer) }

    /// Creates a wrapper around an opaque pointer that will call the free
    /// function on deinit of the object.
    ///
    /// Because the configuration may cause a failure after the creation was
    /// successful, only the creation should be done in the `create` function,
    /// with the `configure` function used to perform post-creation setup. If
    /// a failure occurs during the `configure` function, `free` will be called
    /// to clean up the memory.
    ///
    /// - Parameters:
    ///   - create: The function to create the pointer.
    ///   - configure: Any configuration should be done in this function.
    ///   - free: The function to free the pointer.
    /// - Throws: A LibGit2Error if the results of the functions are not GIT_OK.
    init(
        create: Create,
        configure: Configure? = nil,
        free: @escaping Free
    ) throws {

        git_libgit2_init()
        let free: Free = {
            free($0)
            git_libgit2_shutdown()
        }

        var pointer: OpaquePointer?
        let result = withUnsafeMutablePointer(to: &pointer, create)
        if let error = LibGit2Error(result) { throw error }
        self.pointer = try Unwrap(pointer)
        if let configure = configure {
            let result = configure(self.pointer)
            if let error = LibGit2Error(result) { free(self.pointer); throw error }
        }
        self.free = free
    }

    /// Creates a GitPointer using an OpaquePointer.
    ///
    /// The provided pointer **will not be freed** when deinit is called.
    ///
    /// - Parameter pointer: The pointer to wrap.
    init(_ pointer: OpaquePointer) {
        self.pointer = pointer
        self.free = { _ in }
    }
}

extension GitPointer {

    func check(_ check: (OpaquePointer) -> Int32) -> Bool {
        check(pointer) != 0
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> UnsafePointer<Value> {
        guard let value = get(pointer) else { throw GitKitError.unexpectedNilValue }
        return value
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) throws -> Value {
        guard let value = get(pointer) else { throw GitKitError.unexpectedNilValue }
        return value.pointee
    }

    func get(
        _ get: (OpaquePointer?) -> OpaquePointer?
    ) throws -> GitPointer {
        GitPointer(try Unwrap(get(pointer)))
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> Value
    ) -> Value {
        get(pointer)
    }

    func get<Value>(
        _ get: (UnsafeMutablePointer<Value?>?, OpaquePointer?) -> Int32
    ) throws -> Value {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value) { get($0, pointer) }
        if let error = LibGit2Error(result) { throw error }
        guard let unwrapped = value else { throw GitKitError.unexpectedNilValue }
        return unwrapped
    }
}

extension GitPointer {

    func create(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32
    ) -> Create {
        { create($0, self.pointer) }
    }

    func create<A>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> Create {
        { create($0, self.pointer, a) }
    }

    func create<A, B>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> Create {
        { create($0, self.pointer, a, b) }
    }

    func create<A, B, C>(
        _ create: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> Create {
        { create($0, self.pointer, a, b, c) }
    }
}
