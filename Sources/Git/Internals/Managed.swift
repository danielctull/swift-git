import libgit2

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
    create: Create<Pointer>,
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

  convenience init<T>(
    create: Create<UnsafeMutablePointer<T>>,
    dispose: @escaping (UnsafeMutablePointer<T>) -> Void
  ) throws where Pointer == UnsafeMutablePointer<T> {
    try self.init(create: create) { pointer in
      dispose(pointer)
      pointer.deallocate()
    }
  }

  convenience init(
    create: Create<Pointer?>,
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
  ) -> Create<Value> {
    Create(task, pointer, repeat each parameter)
  }

  func create<Value, each Parameter>(
    _ task:
      @escaping (UnsafeMutablePointer<Value>, Pointer, repeat each Parameter) ->
      Int32,
    _ parameter: repeat each Parameter
  ) -> Create<UnsafeMutablePointer<Value>> {
    Create(pointer: task, pointer, repeat each parameter)
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
    _ task:
      @escaping (UnsafeMutablePointer<Value>, Pointer, repeat each Parameter) ->
      Int32,
    _ parameter: repeat each Parameter
  ) throws -> Value {
    let create = Create<Value> { output in
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

// MARK: - Create

struct Create<Value> {
  private let action: () throws -> Value
  fileprivate init(action: @escaping () throws -> Value) {
    self.action = action
  }
  fileprivate func callAsFunction() throws -> Value {
    try action()
  }
}

extension Create {

  init<each Parameter>(
    _ task:
      @escaping (UnsafeMutablePointer<Value>, repeat each Parameter) -> Int32,
    _ parameter: repeat each Parameter
  ) {
    self.init {
      let pointer = UnsafeMutablePointer<Value>.allocate(capacity: 1)
      defer { pointer.deallocate() }
      let result = task(pointer, repeat each parameter)
      try GitError.check(result)
      return pointer.pointee
    }
  }

  /// Creates a pointer that the caller is responsible for freeing.
  init<T, Pointer, each Parameter>(
    pointer task: @escaping (UnsafeMutablePointer<T>, Pointer, repeat each Parameter) -> Int32,
    _ managed: Pointer,
    _ parameter: repeat each Parameter
  ) where Value == UnsafeMutablePointer<T> {
    self.init {
      let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
      let result = task(pointer, managed, repeat each parameter)
      do {
        try GitError.check(result)
        return pointer
      } catch {
        pointer.deallocate()
        throw error
      }
    }
  }
}
