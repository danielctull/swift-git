protocol GitPointerInitialization {
  init(pointer: Managed<OpaquePointer>) throws
}

extension GitPointerInitialization {

  init(
    create: @escaping Managed<OpaquePointer>.Create,
    free: @escaping Managed<OpaquePointer>.Free
  ) throws {
    try self.init(
      pointer: Managed<OpaquePointer>(
        create: create,
        free: free)
    )
  }
}
