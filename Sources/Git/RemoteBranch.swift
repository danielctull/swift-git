import libgit2

extension Repository {

  public var remoteBranches: some Sequence<RemoteBranch> {
    get throws {
      try GitSequence {

        try Managed(
          create: pointer.create(git_branch_iterator_new, GIT_BRANCH_REMOTE),
          free: git_branch_iterator_free
        )

      } next: { iterator in

        try RemoteBranch(
          pointer: Managed(
            create: iterator.create(firstOutput(of: git_branch_next)),
            free: git_reference_free
          )
        )
      }
    }
  }

  public func branch(
    on remote: Remote.Name,
    named branch: Branch.Name
  ) throws -> RemoteBranch {
    try RemoteBranch.Name(remote: remote, branch: branch).withCString { name in
      try RemoteBranch(
        pointer: Managed(
          create: pointer.create(git_branch_lookup, name, GIT_BRANCH_REMOTE),
          free: git_reference_free
        )
      )
    }
  }
}

// MARK: - RemoteBranch

public struct RemoteBranch: Equatable, Hashable {

  let pointer: Managed<OpaquePointer>
  public let id: ID
  public let target: Object.ID
  public let name: Name
  public let reference: Reference.Name

  init(pointer: Managed<OpaquePointer>) throws {
    pointer.assert(git_reference_is_remote, "Expected remote branch.")
    self.pointer = pointer
    reference = try Reference.Name(pointer: pointer)
    name = try pointer.get(git_branch_name)
      |> unwrap
      |> String.init
      |> Name.init
    target = try Object.ID(reference: pointer)
    id = ID(name: reference)
  }
}

// MARK: - RemoteBranch.ID

extension RemoteBranch {

  public struct ID: Equatable, Hashable, Sendable {
    fileprivate let name: Reference.Name
  }
}

extension RemoteBranch.ID: CustomStringConvertible {
  public var description: String { name.description }
}

// MARK: - RemoteBranch.Name

extension RemoteBranch {

  public struct Name: Equatable, Hashable, Sendable {
    public let remote: Remote.Name
    public let branch: Branch.Name
  }
}

extension RemoteBranch.Name {

  fileprivate init(_ string: String) throws {
    let index = string.firstIndex(of: "/")!
    remote = Remote.Name(string[..<index])
    branch = Branch.Name(string[string.index(after: index)...])
  }
}

extension RemoteBranch.Name: CustomStringConvertible {
  public var description: String { "\(remote)/\(branch)" }
}

extension RemoteBranch.Name {

  func withCString<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try description.withCString(body)
  }
}

// MARK: - CustomDebugStringConvertible

extension RemoteBranch: CustomDebugStringConvertible {
  public var debugDescription: String {
    "RemoteBranch(name: \(name), reference: \(reference), target: \(target.debugDescription))"
  }
}
