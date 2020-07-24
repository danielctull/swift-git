
import Clibgit2

final class GitPointer {

    let pointer: OpaquePointer
    private let free: (OpaquePointer) -> ()

    deinit { free(pointer) }

    init(
        create: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        free: @escaping (OpaquePointer) -> Void
    ) throws {
        git_libgit2_init()
        var pointer: OpaquePointer?
        let result = withUnsafeMutablePointer(to: &pointer, create)
        if let error = LibGit2Error(result) { throw error }
        self.pointer = try Unwrap(pointer)
        self.free = free
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
