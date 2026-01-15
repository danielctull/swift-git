import Clibgit2

extension Repository {

  public func object(for id: Object.ID) throws -> Object {
    try withUnsafePointer(to: id.oid) { oid in
      try Object(
        pointer: Managed(
          create: pointer.create(git_object_lookup, oid, GIT_OBJECT_ANY),
          free: git_object_free
        )
      )
    }
  }
}

// MARK: - Object

public enum Object: Equatable, Hashable {
  case blob(Blob)
  case commit(Commit)
  case tag(AnnotatedTag)
  case tree(Tree)
}

extension Object {

  var pointer: Managed<OpaquePointer> {
    switch self {
    case .blob(let blob): return blob.pointer
    case .commit(let commit): return commit.pointer
    case .tag(let annotatedTag): return annotatedTag.pointer
    case .tree(let tree): return tree.pointer
    }
  }

  init(pointer: Managed<OpaquePointer>) throws {

    let type = pointer.get(git_object_type)

    switch type {

    case GIT_OBJECT_BLOB:
      self = try .blob(Blob(pointer: pointer))

    case GIT_OBJECT_COMMIT:
      self = try .commit(Commit(pointer: pointer))

    case GIT_OBJECT_TAG:
      self = try .tag(AnnotatedTag(pointer: pointer))

    case GIT_OBJECT_TREE:
      self = try .tree(Tree(pointer: pointer))

    default:
      preconditionFailure("Unexpected object type: \(type).")
    }
  }
}

extension Object: Identifiable {

  public var id: ID {
    switch self {
    case .blob(let blob): return blob.id.objectID
    case .commit(let commit): return commit.id.objectID
    case .tag(let tag): return tag.id.objectID
    case .tree(let tree): return tree.id.objectID
    }
  }
}

// MARK: - Object.ID

extension Object {

  public struct ID: Sendable {
    var oid: git_oid
  }
}

extension Object.ID {

  init(_ string: String) throws {
    let oid = try string.withCString { string in
      var oid: git_oid = git_oid()
      try withUnsafeMutablePointer(to: &oid) { oid in
        try GitError.check(git_oid_fromstr(oid, string))
      }
      return oid
    }
    self.init(oid: oid)
  }

  init(_ oid: UnsafePointer<git_oid>) {
    self.init(oid: oid.pointee)
  }

  init(object: Managed<OpaquePointer>) throws {
    self = try object.get(git_object_id) |> Unwrap |> Self.init
  }

  init(reference: Managed<OpaquePointer>) throws {
    let resolved = try Managed<OpaquePointer>(
      create: reference.create(git_reference_resolve),
      free: git_reference_free)

    self = try resolved.get(git_reference_target) |> Unwrap |> Self.init
  }
}

extension Object.ID {

  func withUnsafePointer<Result>(
    _ body: (UnsafePointer<git_oid>) throws -> Result
  ) rethrows -> Result {
    try Swift.withUnsafePointer(to: oid, body)
  }
}

extension Object.ID: CustomStringConvertible {

  public var description: String {
    withUnsafePointer { oid in
      let length = Int(GIT_OID_HEXSZ)
      let cchar = UnsafeMutablePointer<CChar>.allocate(capacity: length)
      defer { cchar.deallocate() }
      git_oid_fmt(cchar, oid)
      return String(cString: cchar)
    }
  }
}

extension Object.ID: CustomDebugStringConvertible {

  public var debugDescription: String {
    String(description.dropLast(33))
  }
}

extension Object.ID: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.withUnsafePointer { lhs in
      rhs.withUnsafePointer { rhs in
        git_oid_cmp(lhs, rhs) == 0
      }
    }
  }
}

extension Object.ID: Hashable {

  public func hash(into hasher: inout Hasher) {
    withUnsafeBytes(of: oid.id) {
      hasher.combine(bytes: $0)
    }
  }
}
