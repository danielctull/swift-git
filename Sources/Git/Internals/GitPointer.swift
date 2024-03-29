
import Clibgit2

@GitActor
final class GitPointer {

    typealias Create = () throws -> OpaquePointer
    typealias Free = (OpaquePointer) -> Void

    let pointer: OpaquePointer
    private let free: Free

    deinit { free(pointer) }

    /// Creates a wrapper around an opaque pointer that will call the free
    /// function on deinit of the object.
    ///
    /// - Parameters:
    ///   - create: The function to create the pointer.
    ///   - free: The function to free the pointer.
    /// - Throws: A ``GitError`` if the results of the functions are not GIT_OK.
    init(
        create: @escaping Create,
        free: @escaping Free
    ) throws {

        git_libgit2_init()
        let free: Free = {
            free($0)
            git_libgit2_shutdown()
        }

        self.pointer = try create()
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

    convenience init(
        create: @escaping (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        free: @escaping Free
    ) throws {
        try self.init(
            create: withUnsafeMutablePointer(create),
            free: free)
    }
}

// MARK: - GitPointer.Create

extension GitPointer {

    func create<each Parameter>(
        _ task: @escaping (UnsafeMutablePointer<OpaquePointer?>?, OpaquePointer?, repeat each Parameter) -> Int32,
        _ parameter: repeat each Parameter
    ) -> Create {
        withUnsafeMutablePointer { output in task(output, self.pointer, repeat each parameter) }
    }
}

// This is for the iterator tasks.
func firstOutput<A, B, C, Value>(
    of task: @escaping (A, UnsafeMutablePointer<B>, C) -> Value
) -> (A, C) -> Value {
    { a, c in
        let b = UnsafeMutablePointer<B>.allocate(capacity: 1)
        defer { b.deallocate() }
        return task(a, b, c)
    }
}

fileprivate func withUnsafeMutablePointer<Value>(
    _ task: @escaping (UnsafeMutablePointer<Value?>) -> Int32
) -> () throws -> Value {
    {
        var value: Value?
        let result = withUnsafeMutablePointer(to: &value, task)
        try GitError.check(result)
        return try Unwrap(value)
    }
}

// MARK: - Equatable

extension GitPointer: Equatable {

    nonisolated
    static func == (lhs: GitPointer, rhs: GitPointer) -> Bool {
        lhs.pointer == rhs.pointer
    }
}

// MARK: - Hashable

extension GitPointer: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer)
    }
}

// MARK: - Perform a task

extension GitPointer {

    func perform<each Parameter>(
        _ task: @escaping (OpaquePointer?, repeat each Parameter) -> Int32,
        _ parameter: repeat each Parameter
    ) throws {
        try GitError.check(task(pointer, repeat each parameter))
    }
}

// MARK: - Get a Value

extension GitPointer {

    func get<each Parameter, Value>(
        _ task: (OpaquePointer?, repeat each Parameter) -> Value,
        _ parameter: repeat each Parameter
    ) -> Value {
        task(pointer, repeat each parameter)
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
}

extension GitPointer {

    func get<Value>(
        _ task: @escaping (UnsafeMutablePointer<Value>, OpaquePointer) -> Int32
    ) throws -> Value {
        let value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
        defer { value.deallocate() }
        let result = task(value, pointer)
        try GitError.check(result)
        return value.pointee
    }

    func get<Parameter, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value>?, OpaquePointer, Parameter) -> Int32,
        _ parameter: Parameter
    ) throws -> Value {
        let value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
        defer { value.deallocate() }
        let result = task(value, pointer, parameter)
        try GitError.check(result)
        return value.pointee
    }
}

// MARK: - Assert

extension GitPointer {

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
        Swift.assert(assertion(pointer) == 1, message(), file: file, line: line)
    }
}
