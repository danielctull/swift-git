import Clibgit2

extension Repository {

  public var branches: GitSequence<Branch> {
    get throws {
      try GitSequence {

        try Managed(
          create: pointer.create(git_branch_iterator_new, GIT_BRANCH_LOCAL),
          free: git_branch_iterator_free)

      } next: { iterator in

        try Branch(
          pointer: Managed(
            create: iterator.create(firstOutput(of: git_branch_next)),
            free: git_reference_free
          )
        )
      }
    }
  }

  /// Create a new branch pointing at a target commit
  ///
  /// The branch name will be checked for validity.
  ///
  /// - Parameters:
  ///   - name: Name for the branch; this name is validated for consistency.
  ///     It should also not conflict with an already existing branch name.
  ///   - commit: Commit to which this branch should point. This object
  ///     must belong to the receiving ``Repository``.
  /// - Returns: The created branch.
  public func createBranch(named name: Branch.Name, at commit: Commit) throws -> Branch {
    try name.withCString { name in
      try Branch(
        pointer: Managed(
          create: pointer.create(git_branch_create, name, commit.pointer.pointer, 0),
          free: git_reference_free
        )
      )
    }
  }

  public func branch(named name: Branch.Name) throws -> Branch {
    try name.withCString { name in
      try Branch(
        pointer: Managed(
          create: pointer.create(git_branch_lookup, name, GIT_BRANCH_LOCAL),
          free: git_reference_free
        )
      )
    }
  }
}

// MARK: - Branch

public struct Branch: Equatable, Hashable, Identifiable {

  let pointer: Managed<OpaquePointer>
  public let id: ID
  public let target: Object.ID
  public let name: Name
  public let reference: Reference.Name

  init(pointer: Managed<OpaquePointer>) throws {
    pointer.assert(git_reference_is_branch, "Expected branch.")
    self.pointer = pointer
    name = try pointer.get(git_branch_name) |> Unwrap |> String.init |> Name.init
    target = try Object.ID(reference: pointer)
    reference = try Reference.Name(pointer: pointer)
    id = ID(name: reference)
  }
}

extension Branch {

  public func move(to name: String, force: Bool = false) throws -> Branch {
    try name.withCString { name in
      try Branch(
        pointer: Managed(
          create: pointer.create(git_branch_move, name, Int32(force)),
          free: git_reference_free
        )
      )
    }
  }

  public var upstream: RemoteBranch {
    get throws {
      try RemoteBranch(
        pointer: Managed(
          create: pointer.create(git_branch_upstream),
          free: git_reference_free
        )
      )
    }
  }

  public func setUpstream(_ remoteBranch: RemoteBranch) throws {
    try remoteBranch.name.withCString { name in
      try pointer.perform(git_branch_set_upstream, name)
    }
  }
}

// MARK: - Branch.ID

extension Branch {

  public struct ID: Equatable, Hashable, Sendable {
    fileprivate let name: Reference.Name
  }
}

extension Branch.ID: CustomStringConvertible {
  public var description: String { name.description }
}

// MARK: - Branch.Name

extension Branch {

  public struct Name: Equatable, Hashable, Sendable {
    private let rawValue: String

    public init(_ string: some StringProtocol) {
      rawValue = String(string)
    }
  }
}

extension Branch.Name: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension Branch.Name: CustomStringConvertible {

  public var description: String { rawValue }
}

extension Branch.Name {

  fileprivate func withCString<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try rawValue.withCString(body)
  }
}

// MARK: - CustomDebugStringConvertible

extension Branch: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Branch(name: \(name), reference: \(reference), target: \(target.debugDescription))"
  }
}
