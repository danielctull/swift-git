import Clibgit2

// MARK: - Tree

public struct Tree: Equatable, Hashable, Identifiable {

  let pointer: Managed<OpaquePointer>
  public let id: ID

  init(pointer: Managed<OpaquePointer>) throws {
    self.pointer = pointer
    id = try ID(objectID: Object.ID(object: pointer))
  }
}

extension Tree {

  public var entries: GitCollection<Entry, Int> {
    GitCollection {
      pointer.get(git_tree_entrycount)
    } element: { index in
      pointer.get(git_tree_entry_byindex, index)! |> Managed<OpaquePointer>.init |> Entry.init
    }
  }
}

// MARK: - Tree.ID

extension Tree {

  public struct ID: Equatable, Hashable, Sendable {
    public let objectID: Object.ID
  }
}

extension Tree.ID: CustomStringConvertible {
  public var description: String { objectID.description }
}

// MARK: - Tree.Entry

extension Tree {

  public struct Entry: Equatable, Hashable {
    let pointer: Managed<OpaquePointer>
    public let target: Object.ID
    public let name: String

    init(pointer: Managed<OpaquePointer>) {
      self.pointer = pointer

      target = pointer.get(git_tree_entry_id)!.pointee |> Object.ID.init
      name = pointer.get(git_tree_entry_name)! |> String.init(cString:)
    }
  }
}
