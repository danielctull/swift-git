protocol GitPointerInitialization {
  init(pointer: GitPointer) throws
}

extension GitPointerInitialization {

  init(
    create: @escaping GitPointer.Create,
    free: @escaping GitPointer.Free
  ) throws {
    try self.init(
      pointer: GitPointer(
        create: create,
        free: free)
    )
  }
}
