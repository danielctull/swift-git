import Clibgit2

extension Repository {

  public var status: GitCollection<StatusEntry> {
    get throws {

      let list = try GitPointer(
        create: pointer.create(git_status_list_new, nil),
        free: git_status_list_free)

      return GitCollection {
        list.get(git_status_list_entrycount)
      } element: { index in
        list.get(git_status_byindex, index)! |> StatusEntry.init
      }
    }
  }
}

// MARK: - StatusEntry

public struct StatusEntry {
  public let status: Status
  public let headToIndex: Diff.Delta?
  public let indexToWorkingDirectory: Diff.Delta?
}

extension StatusEntry {

  fileprivate init(_ entry: UnsafePointer<git_status_entry>) {
    let entry = entry.pointee
    status = Status(entry.status)
    if let head_to_index = entry.head_to_index {
      headToIndex = Diff.Delta(head_to_index.pointee)
    } else {
      headToIndex = nil
    }
    if let index_to_workdir = entry.index_to_workdir {
      indexToWorkingDirectory = Diff.Delta(index_to_workdir.pointee)
    } else {
      indexToWorkingDirectory = nil
    }
  }
}

// MARK: - Status

public struct Status: OptionSet, Equatable, Hashable, Sendable {
  public let rawValue: Option
  public init(rawValue: Option) {
    self.rawValue = rawValue
  }
}

extension Status: GitOptionSet {

  typealias OptionType = git_status_t

  public static let current = Self(GIT_STATUS_CURRENT)

  public static let indexNew = Self(GIT_STATUS_INDEX_NEW)
  public static let indexModified = Self(GIT_STATUS_INDEX_MODIFIED)
  public static let indexDeleted = Self(GIT_STATUS_INDEX_DELETED)
  public static let indexRenamed = Self(GIT_STATUS_INDEX_RENAMED)
  public static let indexTypeChange = Self(GIT_STATUS_INDEX_TYPECHANGE)

  public static let workingTreeNew = Self(GIT_STATUS_WT_NEW)
  public static let workingTreeModified = Self(GIT_STATUS_WT_MODIFIED)
  public static let workingTreeDeleted = Self(GIT_STATUS_WT_DELETED)
  public static let workingTreeTypeChange = Self(GIT_STATUS_WT_TYPECHANGE)
  public static let workingTreeRenamed = Self(GIT_STATUS_WT_RENAMED)
  public static let workingTreeUnreadable = Self(GIT_STATUS_WT_UNREADABLE)

  public static let ignored = Self(GIT_STATUS_IGNORED)
  public static let conflicted = Self(GIT_STATUS_CONFLICTED)
}
