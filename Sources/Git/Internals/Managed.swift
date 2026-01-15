import Clibgit2

final class Managed<Pointer> {

  typealias Create = () throws -> Pointer
  typealias Free = (Pointer) -> Void

  let pointer: Pointer
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

  /// Creates a ``Managed`` object.
  ///
  /// The provided pointer **will not be freed** when deinit is called.
  ///
  /// - Parameter pointer: The pointer to wrap.
  init(_ pointer: Pointer) {
    self.pointer = pointer
    self.free = { _ in }
  }

  convenience init(
    create: @escaping (UnsafeMutablePointer<Pointer?>) -> Int32,
    free: @escaping Free
  ) throws {
    try self.init(
      create: withUnsafeMutablePointer(create),
      free: free)
  }
}

// MARK: - Managed.Create

extension Managed {

  func create<Value, each Parameter>(
    _ task:
      @escaping (UnsafeMutablePointer<Value?>?, Pointer?, repeat each Parameter) ->
      Int32,
    _ parameter: repeat each Parameter
  ) -> Managed<Value>.Create {
    withUnsafeMutablePointer { output in task(output, self.pointer, repeat each parameter) }
  }
}

private func withUnsafeMutablePointer<Value>(
  _ task: @escaping (UnsafeMutablePointer<Value?>) -> Int32
) -> Managed<Value>.Create {
  {
    var value: Value?
    let result = withUnsafeMutablePointer(to: &value, task)
    try GitError.check(result)
    return try Unwrap(value)
  }
}

// MARK: - Equatable

extension Managed: Equatable where Pointer: Equatable {

  static func == (lhs: Managed<Pointer>, rhs: Managed<Pointer>) -> Bool {
    lhs.pointer == rhs.pointer
  }
}

// MARK: - Hashable

extension Managed: Hashable where Pointer: Hashable {

  func hash(into hasher: inout Hasher) {
    hasher.combine(pointer)
  }
}

// MARK: - Perform a task

extension Managed {

  func perform<each Parameter>(
    _ task: @escaping (Pointer, repeat each Parameter) -> Int32,
    _ parameter: repeat each Parameter
  ) throws {
    try GitError.check(task(pointer, repeat each parameter))
  }
}

// MARK: - Get a Value

extension Managed {

  func get<Value, each Parameter>(
    _ task: (Pointer, repeat each Parameter) -> Value,
    _ parameter: repeat each Parameter
  ) -> Value {
    task(pointer, repeat each parameter)
  }

  func get<Value, each Parameter>(
    _ task: @escaping (UnsafeMutablePointer<Value>, Pointer, repeat each Parameter) -> Int32,
    _ parameter: repeat each Parameter
  ) throws -> Value {
    let value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
    defer { value.deallocate() }
    let result = task(value, pointer, repeat each parameter)
    try GitError.check(result)
    return value.pointee
  }
}

// MARK: - Assert

extension Managed {

  /// Performs a traditional C-style assert with a message.
  ///
  /// Use this function for internal sanity checks that are active during
  /// testing but do not impact performance of shipping code.
  func assert(
    _ assertion: @escaping (Pointer) -> Int32,
    _ message: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    Swift.assert(assertion(pointer) == 1, message(), file: file, line: line)
  }
}
