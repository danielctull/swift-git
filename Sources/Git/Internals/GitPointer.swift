
import Clibgit2

final class GitPointer {

    typealias Create = GitTask<Void, OpaquePointer>
    typealias Configure = GitTask<OpaquePointer, Void>
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

        self.pointer = try create()
        if let configure = configure {
            do { try configure(self.pointer) }
            catch { free(self.pointer); throw error }
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

    func get<Value>(
        _ task: (OpaquePointer) -> Value
    ) -> Value {
        task(pointer)
    }

    func get<A, Value>(
        _ task: (OpaquePointer, A) -> Value,
        _ a: A
    ) -> Value {
        task(pointer, a)
    }

    func get<CType, Value>(
        _ task: @escaping (OpaquePointer) -> CType,
        as conversion: (CType) throws -> Value
    ) throws -> Value {
        let task = GitTask { task(self.pointer) }
        return try conversion(task())
    }

    func get<A, CType, Value>(
        _ task: @escaping (OpaquePointer, A) -> CType,
        _ a: A,
        as conversion: (CType) throws -> Value
    ) throws -> Value {
        let task = GitTask { task(self.pointer, a) }
        return try conversion(task())
    }

    func get<CType, Value>(
        _ task: @escaping (UnsafeMutablePointer<CType?>, OpaquePointer) -> Int32,
        as conversion: (CType) throws -> Value
    ) throws -> Value {
        let task = GitTask<Void, CType> { task($0, self.pointer) }
        return try conversion(task())
    }
}

extension GitPointer {

    func check(_ check: (OpaquePointer) -> Int32) -> Bool {
        check(pointer) != 0
    }

    /// Performs a traditional C-style assert with a message.
    ///
    /// Use this function for internal sanity checks that are active during
    /// testing but do not impact performance of shipping code.
    func assert(
        _ assertion: @escaping (OpaquePointer) -> Int32,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        Swift.assert(assertion(pointer) == 1, message())
    }
}
