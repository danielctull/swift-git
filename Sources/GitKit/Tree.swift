
import Cgit2
import Tagged

public struct Tree: Identifiable {
    let tree: GitPointer
    public typealias ID = Tagged<Tree, Object.ID>
    public let id: ID
    public let entries: [Entry]
}

extension Tree {

    public struct Entry {
        public let target: Object.ID
        public let name: String
    }
}

// MARK: - Git Initialisers

extension Tree {

    init(_ tree: GitPointer) throws {
        self.tree = tree
        id = try ID(object: tree)

        entries = try (0..<tree.get(git_tree_entrycount)).map { index in
            let entry = GitPointer(tree.get { git_tree_entry_byindex($0, index) })
            return try Entry(entry)
        }
    }
}

extension Tree.Entry {

    init(_ entry: GitPointer) throws {
        target = try Object.ID(entry.get(git_tree_entry_id))
        name = try Unwrap(String(validatingUTF8: entry.get(git_tree_entry_name)))
    }
}
