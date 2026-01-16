import Clibgit2

final class Managed<Pointer> {

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
    create: Create,
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

  convenience init(
    create: Managed<Pointer?>.Create,
    free: @escaping Free
  ) throws {
    try self.init(
      create: Create { try Unwrap(create()) },
      free: free
    )
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

// MARK: - Create a new Managed pointer

extension Managed {

  func create<Value, each Parameter>(
    _ task:
      @escaping (UnsafeMutablePointer<Value>, Pointer, repeat each Parameter) ->
      Int32,
    _ parameter: repeat each Parameter
  ) -> Managed<Value>.Create {
    Managed<Value>.Create { output in
      task(output, self.pointer, repeat each parameter)
    }
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
    let create = Managed<Value>.Create { output in
      task(output, self.pointer, repeat each parameter)
    }
    return try create()
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

// MARK: - Managed.Create

extension Managed {

  struct Create {
    private let action: () throws -> Pointer
    fileprivate init(action: @escaping () throws -> Pointer) {
      self.action = action
    }
    fileprivate func callAsFunction() throws -> Pointer {
      try action()
    }
  }
}

extension Managed.Create {

  init(
    _ task: @escaping (UnsafeMutablePointer<Pointer>) -> Int32
  ) {
    self.init {
      let pointer = UnsafeMutablePointer<Pointer>.allocate(capacity: 1)
      defer { pointer.deallocate() }
      let result = task(pointer)
      try GitError.check(result)
      return pointer.pointee
    }
  }
}
