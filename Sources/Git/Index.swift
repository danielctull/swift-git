import Clibgit2

public struct Index: Equatable, Hashable {
  let pointer: Managed<OpaquePointer>
}

extension Repository {

  public var index: Index {
    get throws {
      try Index(
        create: pointer.create(git_repository_index),
        free: git_index_free)
    }
  }
}

extension Index {

  public struct Entry {
    public let objectID: Object.ID
  }

  public var entries: GitCollection<Index.Entry> {
    GitCollection {
      pointer.get(git_index_entrycount)
    } element: { index in
      pointer.get(git_index_get_byindex, index)!.pointee |> Entry.init
    }
  }
}

extension Index.Entry {

  fileprivate init(_ entry: git_index_entry) {
    objectID = Object.ID(oid: entry.id)
  }
}

// MARK: - GitPointerInitialization

extension Index: GitPointerInitialization {}
