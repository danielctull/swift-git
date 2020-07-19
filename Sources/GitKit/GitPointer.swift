
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

    func get<Value>(_ get: (OpaquePointer?) -> UnsafePointer<Value>?) -> Value {
        get(pointer)!.pointee
    }

    func get<Value>(_ get: (UnsafeMutablePointer<Value?>?, OpaquePointer?) -> Int32) throws -> Value {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value) { get($0, pointer) }
        if let error = GitError(result) { throw error }
        return value!
    }
}
