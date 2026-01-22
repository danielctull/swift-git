import Foundation
import libgit2

extension Repository {

  /// List names of linked working trees.
  public var worktrees: some RandomAccessCollection<Worktree.Name> {
    get throws {
      let array = try Managed(
        create: pointer.create(git_worktree_list),
        dispose: git_strarray_dispose
      )

      return GitCollection {
        array.pointer.pointee.count
      } element: { index in
        let name = String(cString: array.pointer.pointee.strings[index]!)
        return Worktree.Name(name)
      }
    }
  }
}

// MARK: - Worktree

public enum Worktree {}

// MARK: - Worktree.Name

extension Worktree {

  public struct Name: Equatable, Hashable, Sendable {
    private let rawValue: String

    public init(_ string: some StringProtocol) {
      rawValue = String(string)
    }
  }
}

extension Worktree.Name: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension Worktree.Name: CustomStringConvertible {

  public var description: String { rawValue }
}

extension Worktree.Name {

  fileprivate func withCString<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try rawValue.withCString(body)
  }
}
