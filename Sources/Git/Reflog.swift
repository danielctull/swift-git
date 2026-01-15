import Clibgit2

extension Repository {

  public var reflog: Reflog {
    get throws {
      try reflog(named: "HEAD")
    }
  }

  public func reflog(named name: Reflog.Name) throws -> Reflog {
    try name.withCString { name in
      try Reflog(
        pointer: Managed(
          create: pointer.create(git_reflog_read, name),
          free: git_reflog_free
        )
      )
    }
  }

  public func renameReflog(from old: Reflog.Name, to new: Reflog.Name) throws {
    try old.withCString { old in
      try new.withCString { new in
        try pointer.perform(git_reflog_rename, old, new)
      }
    }
  }

  public func deleteReflog(named name: Reflog.Name) throws {
    try name.withCString { name in
      try pointer.perform(git_reflog_delete, name)
    }
  }
}

// MARK: - Reflog

public struct Reflog: Equatable, Hashable {
  let pointer: Managed<OpaquePointer>
}

extension Reflog {

  public var items: GitCollection<Item, Int> {
    GitCollection {
      pointer.get(git_reflog_entrycount)
    } element: { index in
      Item(
        pointer: Managed<OpaquePointer>(pointer.get(git_reflog_entry_byindex, index)!),
        index: index)
    }
  }

  /// Add a new entry to the in-memory reflog.
  ///
  /// To save the addition to disk, you should call ``write()``.
  ///
  /// - Parameter item: The item to append.
  public func append(_ item: Reflog.Item.Draft) throws {
    try item.id.withUnsafePointer { oid in
      try item.message.withCString { message in
        try item.committer.withUnsafePointer { committer in
          try pointer.perform(git_reflog_append, oid, committer, message)
        }
      }
    }
  }

  /// Remove an entry from the reflog.
  ///
  /// - Parameter item: The item to remove.
  public func remove(_ item: Reflog.Item) throws {
    try pointer.perform(git_reflog_drop, item.id.rawValue, Int32(true))
  }

  /// Write the reflog back to disk using an atomic file lock.
  public func write() throws {
    try pointer.perform(git_reflog_write)
  }
}

// MARK: - Reflog.Name

extension Reflog {

  public struct Name: Equatable, Hashable, Sendable {
    private let rawValue: String

    public init(_ string: some StringProtocol) {
      rawValue = String(string)
    }
  }
}

extension Reflog.Name: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension Reflog.Name: CustomStringConvertible {

  public var description: String { rawValue }
}

extension Reflog.Name {

  fileprivate func withCString<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try rawValue.withCString(body)
  }
}

// MARK: - Reflog.Item

extension Reflog {

  public struct Item: Equatable, Hashable, Identifiable, Sendable {
    public let id: ID
    public let message: String
    public let committer: Signature
    public let old: Object.ID
    public let new: Object.ID
  }
}

extension Reflog.Item {

  fileprivate init(pointer: Managed<OpaquePointer>, index: Int) {
    self.init(
      id: ID(rawValue: index),
      message: pointer.get(git_reflog_entry_message)! |> String.init(cString:),
      committer: pointer.get(git_reflog_entry_committer)! |> Signature.init,
      old: pointer.get(git_reflog_entry_id_old)!.pointee |> Object.ID.init,
      new: pointer.get(git_reflog_entry_id_new)!.pointee |> Object.ID.init)
  }
}

// MARK: - Reflog.Item.ID

extension Reflog.Item {

  public struct ID: Equatable, Hashable, Sendable {
    let rawValue: Int
  }
}

// MARK: - Reflog.Item.Draft

extension Reflog.Item {

  public struct Draft: Equatable, Hashable, Sendable {

    public let id: Object.ID
    public let message: String
    public let committer: Signature

    public init(id: Object.ID, message: String, committer: Signature) {
      self.id = id
      self.message = message
      self.committer = committer
    }
  }
}
