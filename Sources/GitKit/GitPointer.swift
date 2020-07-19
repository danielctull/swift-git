
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
        if let error = GitError(result) { throw error }
        self.pointer = pointer!
        self.free = free
    }
}

extension GitPointer {

    func check(_ check: (OpaquePointer) -> Int32) -> Bool {
        let result = check(pointer)
        return result != 0
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) -> UnsafePointer<Value> {
        get(pointer)!
    }

    func get<Value>(
        _ get: (OpaquePointer?) -> UnsafePointer<Value>?
    ) -> Value {
        get(pointer)!.pointee
    }

    func get<Value>(
        _ get: (UnsafeMutablePointer<Value?>?, OpaquePointer?) -> Int32
    ) throws -> Value {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value) { get($0, pointer) }
        if let error = GitError(result) { throw error }
        return value!
    }

    func get(
        _ get: (UnsafeMutablePointer<git_strarray>?, OpaquePointer?) -> Int32
    ) throws -> [String] {

        let strarray = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        defer { strarray.deallocate() }
        let result = get(strarray, pointer)
        if let error = GitError(result) { throw error }
        let strings = Array(strarray.pointee)
        git_strarray_free(strarray)
        return strings
    }
}
