
import Clibgit2
import Tagged

// MARK: - Tree

public struct Tree: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Tree, Object.ID>
    public let id: ID

    init(pointer: GitPointer) throws {
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

    public struct Entry: GitReference {
        let pointer: GitPointer
        public let target: Object.ID
        public let name: String

        init(pointer: GitPointer) throws {
            self.pointer = pointer
            target = try Object.ID(pointer.get(git_tree_entry_id))
            name = try pointer.task(for: git_tree_entry_name).map(String.init)()
        }
    }
}
