
import Clibgit2
import Tagged

// MARK: - Tree

public struct Tree: GitReference, Identifiable {
    let pointer: GitPointer
    public typealias ID = Tagged<Tree, Object.ID>
    public let id: ID
}

extension Tree {

    init(_ pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)
    }
}

extension Tree {

    public var entries: [Entry] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_tree_entrycount,
                element: git_tree_entry_byindex
            )
            .map(Unwrap)
            .map(GitPointer.init)
            .map(Entry.init)
        }
    }
}

// MARK: - Tree.Entry

extension Tree {

    public struct Entry {
        public let target: Object.ID
        public let name: String
    }
}

extension Tree.Entry {

    init(_ entry: GitPointer) throws {
        target = try Object.ID(entry.get(git_tree_entry_id))
        name = try Unwrap(String(validatingUTF8: entry.get(git_tree_entry_name)))
    }
}
