
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

            target = try pointer
                .task(git_tree_entry_id)
                .map(Unwrap)
                .map(\.pointee)
                .map(Object.ID.init)()

            name = try pointer.get(git_tree_entry_name, as: String.init)
        }
    }
}
