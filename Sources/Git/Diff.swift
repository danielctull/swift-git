import libgit2

extension Repository {

  public func diff(from tree1: Tree, to tree2: Tree) throws -> Diff {
    try Diff(
      pointer: Managed(
        create: pointer.create(
          git_diff_tree_to_tree,
          tree1.pointer.pointer,
          tree2.pointer.pointer,
          nil
        ),
        free: git_diff_free
      )
    )
  }

  public func object(for id: Diff.File.ID) throws -> Object {
    try object(for: id.objectID)
  }
}

// MARK: - Diff

public struct Diff: Equatable, Hashable {
  let pointer: Managed<OpaquePointer>
}

extension Diff {

  public var deltas: some RandomAccessCollection<Delta> {
    GitCollection {
      pointer.get(git_diff_num_deltas)
    } element: { index in
      pointer.get(git_diff_get_delta, index)!.pointee |> Delta.init
    }
  }
}

// MARK: - Diff.Hunk

extension Diff {

  public struct Hunk {
    public let lines: ClosedRange<LineNumber>
    public let file: File
  }

  public var hunks: [Hunk] {
    get throws {
      var hunks: [Hunk] = []

      try withUnsafeMutablePointer(to: &hunks) {
        try pointer.perform(
          git_diff_foreach,
          nil,
          nil,
          { delta, hunk, hunks in
            GitError.catching {
              let hunks = try unwrap(hunks).assumingMemoryBound(to: [Hunk].self)
              let delta = try unwrap(delta?.pointee)
              let hunk = try unwrap(hunk?.pointee)
              hunks.pointee.append(try Hunk(delta: delta, hunk: hunk))
            }
          },
          nil,
          $0
        )
      }

      return hunks
    }
  }
}

extension Diff.Hunk {

  fileprivate init(delta: git_diff_delta, hunk: git_diff_hunk) throws {
    let lines = ClosedRange(start: hunk.new_start, count: hunk.new_lines)
    let file = try unwrap(Diff.File(delta.new_file))
    self.init(lines: lines, file: file)
  }
}

// MARK: - Diff.Delta

extension Diff {

  public struct Delta {
    public let status: Status
    public let from: File?
    public let to: File?
    public let flags: Flags
  }
}

extension Diff.Delta {

  init(_ delta: git_diff_delta) {
    flags = Diff.Flags(rawValue: delta.flags)
    from = Diff.File(delta.old_file)
    to = Diff.File(delta.new_file)
    status = Diff.Delta.Status(
      status: delta.status,
      similarity: delta.similarity
    )
  }
}

// MARK: - Diff.Delta.Status

extension Diff.Delta {

  public enum Status: Equatable {

    /// No changes.
    case unmodified

    /// Entry does not exist in old version.
    case added

    /// Entry does not exist in new version.
    case deleted

    /// Entry content changed between old and new.
    case modified

    /// Entry was renamed between old and new.
    case renamed(similarity: Int)

    /// Entry was copied from another old entry.
    case copied(similarity: Int)

    /// Entry is ignored item in workdir.
    case ignored

    /// Entry is untracked item in workdir.
    case untracked

    /// Type of entry changed between old and new.
    case typeChange

    /// Entry is unreadable.
    case unreadable

    /// Entry in the index is conflicted.
    case conflicted
  }
}

extension Diff.Delta.Status {

  fileprivate init(status: git_delta_t, similarity: UInt16) {
    switch status {
    case GIT_DELTA_UNMODIFIED: self = .unmodified
    case GIT_DELTA_ADDED: self = .added
    case GIT_DELTA_DELETED: self = .deleted
    case GIT_DELTA_MODIFIED: self = .modified
    case GIT_DELTA_RENAMED: self = .renamed(similarity: Int(similarity))
    case GIT_DELTA_COPIED: self = .copied(similarity: Int(similarity))
    case GIT_DELTA_IGNORED: self = .ignored
    case GIT_DELTA_UNTRACKED: self = .untracked
    case GIT_DELTA_TYPECHANGE: self = .typeChange
    case GIT_DELTA_UNREADABLE: self = .unreadable
    case GIT_DELTA_CONFLICTED: self = .conflicted
    default: preconditionFailure("Unexpected delta status: \(status)")
    }
  }
}

// MARK: - Diff.File

extension Diff {

  public struct File: Identifiable, Sendable {
    public let id: ID
    public let path: String
    public let size: UInt64
    public let flags: Flags
  }
}

extension Diff.File {

  init?(_ file: git_diff_file) {
    flags = Diff.Flags(rawValue: file.flags)
    guard flags.contains(.exists) else { return nil }
    id = ID(objectID: Object.ID(oid: file.id))
    path = String(cString: file.path)
    size = file.size
  }
}

// MARK: - Diff.File.ID

extension Diff.File {

  public struct ID: Equatable, Hashable, Sendable {
    public let objectID: Object.ID
  }
}

extension Diff.File.ID: CustomStringConvertible {
  public var description: String { objectID.description }
}

// MARK: - Diff.Flags

extension Diff {

  /// Flags for the delta object and the file objects on each side.
  ///
  /// These flags are used for both the `flags` values of `Diff.Delta` and
  /// `Diff.File` objects representing the old and new sides of the delta.
  public struct Flags: OptionSet, Equatable, Hashable, Sendable {
    public let rawValue: Option
    public init(rawValue: Option) {
      self.rawValue = rawValue
    }
  }
}

extension Diff.Flags: GitOptionSet {

  typealias OptionType = git_diff_flag_t

  /// File(s) treated as binary data
  public static let binary = Self(GIT_DIFF_FLAG_BINARY)

  /// File(s) treated as text data
  public static let notBinary = Self(GIT_DIFF_FLAG_NOT_BINARY)

  /// `id` value is known correct
  public static let validID = Self(GIT_DIFF_FLAG_VALID_ID)

  /// File exists at this side of the delta
  public static let exists = Self(GIT_DIFF_FLAG_EXISTS)

  /// File size value is known correct
  public static let validSize = Self(GIT_DIFF_FLAG_VALID_SIZE)
}

// MARK: - Diff.File.Mode

//    extension Diff.File {
//
//        public struct Mode: OptionSet {
//
//            public let rawValue: UInt16
//            public init(rawValue: UInt16) {
//                self.rawValue = rawValue
//            }
//
//            private init(_ mode: git_filemode_t) {
//                self.init(rawValue: mode.rawValue)
//            }
//
//            public static let unreadable = Self(GIT_FILEMODE_UNREADABLE)
//            public static let tree = Self(GIT_FILEMODE_TREE)
//            public static let blob = Self(GIT_FILEMODE_BLOB)
//            public static let blobExecutable = Self(GIT_FILEMODE_BLOB_EXECUTABLE)
//            public static let link = Self(GIT_FILEMODE_LINK)
//            public static let commit = Self(GIT_FILEMODE_COMMIT)
//        }
//    }
