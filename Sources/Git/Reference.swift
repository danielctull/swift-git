import libgit2

extension Repository {

  /// Retrieve and resolve the reference pointed at by HEAD.
  public var head: Reference {
    get throws {
      try Reference(
        pointer: Managed(
          create: pointer.create(git_repository_head),
          free: git_reference_free
        )
      )
    }
  }

  public var references: GitSequence<Reference> {
    get throws {
      try GitSequence {

        try Managed(
          create: pointer.create(git_reference_iterator_new),
          free: git_reference_iterator_free
        )

      } next: { iterator in

        try Reference(
          pointer: Managed(
            create: iterator.create(git_reference_next),
            free: git_reference_free
          )
        )
      }
    }
  }

  /// Lookup a reference by id in a repository.
  public func reference(for id: Reference.ID) throws -> Reference {
    try id.name.withCString { id in
      try Reference(
        pointer: Managed(
          create: pointer.create(git_reference_lookup, id),
          free: git_reference_free
        )
      )
    }
  }

  /// Delete an existing reference by id.
  ///
  /// This method removes the reference from the repository without looking at
  /// its old value.
  public func remove(_ id: Reference.ID) throws {
    try remove(reference(for: id))
  }

  /// Delete an existing reference.
  ///
  /// This method removes the reference from the repository without looking at
  /// its old value.
  public func remove(_ reference: Reference) throws {
    try reference.id.name.rawValue.withCString { id in
      try pointer.perform(git_reference_remove, id)
    }
  }

  public func delete(_ reference: Reference) throws {
    try reference.pointer.perform(git_reference_delete)
  }
}

// MARK: - Reference

public enum Reference: Equatable, Hashable {
  case branch(Branch)
  case note(Note)
  case remoteBranch(RemoteBranch)
  case tag(Tag)
}

extension Reference {

  var pointer: Managed<OpaquePointer> {
    switch self {
    case .branch(let branch): return branch.pointer
    case .note(let note): return note.pointer
    case .remoteBranch(let remoteBranch): return remoteBranch.pointer
    case .tag(let tag): return tag.pointer
    }
  }

  init(pointer: Managed<OpaquePointer>) throws {

    switch pointer {

    case let pointer where pointer.get(git_reference_is_branch) |> Bool.init:
      self = try .branch(Branch(pointer: pointer))

    case let pointer where pointer.get(git_reference_is_note) |> Bool.init:
      self = try .note(Note(pointer: pointer))

    case let pointer where pointer.get(git_reference_is_remote) |> Bool.init:
      self = try .remoteBranch(RemoteBranch(pointer: pointer))

    case let pointer where pointer.get(git_reference_is_tag) |> Bool.init:
      self = try .tag(Tag(pointer: pointer))

    default:
      struct UnknownReferenceType: Error {}
      throw UnknownReferenceType()
    }
  }
}

extension Reference {

  public var target: Object.ID {
    switch self {
    case .branch(let branch): return branch.target
    case .note(let note): return note.target
    case .remoteBranch(let remoteBranch): return remoteBranch.target
    case .tag(let tag): return tag.target
    }
  }
}

// MARK: - Identifiable

extension Reference {

  public struct ID: Equatable, Hashable, Sendable {
    let name: Name
  }
}

extension Reference.ID: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(name: Reference.Name(value))
  }
}

extension Reference.ID: CustomStringConvertible {

  public var description: String { name.description }
}

extension Reference: Identifiable {

  public var id: ID {
    switch self {
    case .branch(let branch): return ID(name: branch.reference)
    case .note(let note): return ID(name: note.reference)
    case .remoteBranch(let remoteBranch):
      return ID(name: remoteBranch.reference)
    case .tag(let tag): return ID(name: tag.reference)
    }
  }
}

// MARK: - CustomDebugStringConvertible

extension Reference: CustomDebugStringConvertible {

  public var debugDescription: String {
    switch self {
    case .branch(let branch): return branch.debugDescription
    case .note(let note): return note.debugDescription
    case .remoteBranch(let remoteBranch): return remoteBranch.debugDescription
    case .tag(let tag): return tag.debugDescription
    }
  }
}

// MARK: - Name

extension Reference {

  /// The full name of a reference.
  public struct Name: Equatable, Hashable, Sendable {
    let rawValue: String

    init(_ rawValue: String) {
      self.rawValue = rawValue
    }
  }
}

extension Reference.Name: CustomStringConvertible {

  public var description: String { rawValue }
}

extension Reference.Name {

  fileprivate func withCString<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try rawValue.withCString(body)
  }
}

extension Reference.Name {

  init(pointer: Managed<OpaquePointer>) throws {
    try self.init(
      pointer.get(git_reference_name) |> Unwrap |> String.init(cString:)
    )
  }
}
