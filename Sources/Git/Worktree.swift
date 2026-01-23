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

  /// Add a new working tree for the repository at the given path.
  ///
  /// If a reference is provided, it will be checked out in the new working
  /// tree.
  public func addWorktree(
    named name: Worktree.Name,
    at path: URL,
    reference: Reference? = nil
  ) throws -> Worktree {
    try name.withCString { name in
      try path.withUnsafeFileSystemRepresentation { path in

        var options = git_worktree_add_options()

        git_worktree_add_options_init(
          &options,
          UInt32(GIT_WORKTREE_ADD_OPTIONS_VERSION)
        )

        if let reference {
          options.ref = reference.pointer.pointer
        }

        return try withUnsafePointer(to: options) { options in
          try Worktree(
            pointer: Managed(
              create: pointer.create(git_worktree_add, name, path, options),
              free: git_worktree_free
            )
          )
        }
      }
    }
  }
}

// MARK: - Worktree

public struct Worktree: Equatable, Hashable, Identifiable {

  let pointer: Managed<OpaquePointer>
  public let id: ID
  public let name: Name
  public let path: URL

  init(pointer: Managed<OpaquePointer>) throws {
    self.pointer = pointer
    name = try pointer.get(git_worktree_name)
      |> Unwrap
      |> String.init(cString:)
      |> Name.init
    id = ID(name: name)
    path = try pointer.get(git_worktree_path)
      |> Unwrap
      |> String.init(cString:)
      |> URL.init(fileURLWithPath:)
  }
}

// MARK: - Worktree.ID

extension Worktree {

  public struct ID: Equatable, Hashable, Sendable {
    fileprivate let name: Name
  }
}

extension Worktree.ID: CustomStringConvertible {
  public var description: String { name.description }
}

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
