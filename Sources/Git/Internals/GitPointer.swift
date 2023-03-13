
import Clibgit2

final class GitPointer {

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
        create: @autoclosure () throws -> OpaquePointer,
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

    convenience init(
        create: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        configure: Configure? = nil,
        free: @escaping Free
    ) throws {

        try self.init(create: {
            var pointer: OpaquePointer?
            let result = withUnsafeMutablePointer(to: &pointer, create)
            try GitError.check(result)
            return try Unwrap(pointer)
        }(), configure: configure, free: free)
    }
}

// MARK: - Perform a task

extension GitPointer {

    func perform(
        _ task: @escaping (OpaquePointer) -> Int32
    ) throws {
        try GitError.check(task(pointer))
    }

    func perform<A>(
        _ task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) throws {
        try GitError.check(task(pointer, a))
    }

    func perform<A, B>(
        _ task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) throws {
        try GitError.check(task(pointer, a, b))
    }

    func perform<A, B, C>(
        _ task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) throws {
        try GitError.check(task(pointer, a, b, c))
    }

    func perform<A, B, C, D>(
        _ task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) throws {
        try GitError.check(task(pointer, a, b, c, d))
    }
}

// MARK: - Get a Value

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

    func get<A, B, Value>(
        _ task: (OpaquePointer, A, B) -> Value,
        _ a: A,
        _ b: B
    ) -> Value {
        task(pointer, a, b)
    }

    func get<A, B, C, Value>(
        _ task: (OpaquePointer, A, B, C) -> Value,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> Value {
        task(pointer, a, b, c)
    }

    func get<A, B, C, D, Value>(
        _ task: (OpaquePointer, A, B, C, D) -> Value,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> Value {
        task(pointer, a, b, c, d)
    }
}

extension GitPointer {

    func get<Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer) -> Int32
    ) throws -> Value {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value) { task($0, pointer) }
        try GitError.check(result)
        return try Unwrap(value)
    }

    func get<A, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) throws -> Value {
        try get { output, pointer in task(output, pointer, a) }
    }

    func get<A, B, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) throws -> Value {
        try get { output, pointer in task(output, pointer, a, b) }
    }

    func get<A, B, C, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) throws -> Value {
        try get { output, pointer in task(output, pointer, a, b, c) }
    }

    func get<A, B, C, D, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) throws -> Value {
        try get { output, pointer in task(output, pointer, a, b, c, d) }
    }
}

// MARK: - Assert

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
