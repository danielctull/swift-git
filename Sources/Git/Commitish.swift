public struct Commitish {
  let pointer: GitPointer
  private init(_ pointer: GitPointer) {
    self.pointer = pointer
  }
}

extension Commitish {
  public static func commit(_ commit: Commit) -> Self { Self(commit.pointer) }
  public static func tag(_ tag: Tag) -> Self { Self(tag.pointer) }
}
