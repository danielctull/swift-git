
import Clibgit2
import Tagged

public struct Tree: Identifiable {
    let tree: GitPointer
    public typealias ID = Tagged<Tree, Object.ID>
    public let id: ID
    public let entries: [Entry]

    init(_ tree: GitPointer) throws {
        self.tree = tree
        id = try ID(rawValue: Object.ID(tree.get(git_object_id)))

        entries = try (0..<tree.get(git_tree_entrycount)).map { index in
            let entry = GitPointer(tree.get { git_tree_entry_byindex($0, index) })
            return try Entry(entry)
        }
    }
}

extension Tree {

    public struct Entry {

        public let name: String

        init(_ entry: GitPointer) throws {
            name = try Unwrap(String(validatingUTF8: entry.get(git_tree_entry_name)))
        }
    }
}
