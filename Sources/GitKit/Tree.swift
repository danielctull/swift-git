
import Clibgit2
import Tagged

// MARK: - Tree

public struct Tree: Identifiable {
    let tree: GitPointer
    public typealias ID = Tagged<Tree, Object.ID>
    public let id: ID
}

extension Tree {

    @GitActor
    init(_ tree: GitPointer) throws {
        self.tree = tree
        id = try ID(object: tree)
    }
}

extension Tree {

    @GitActor
    public var entries: [Entry] {
        get throws {
            try GitCollection(
                pointer: tree,
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

    @GitActor
    init(_ entry: GitPointer) throws {
        target = try Object.ID(entry.get(git_tree_entry_id))
        name = try Unwrap(String(validatingUTF8: entry.get(git_tree_entry_name)))
    }
}
