
import Cgit2

// MARK: - Tree

public struct Tree: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID

    @GitActor
    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(objectID: Object.ID(object: pointer))
    }
}

extension Tree {

    @GitActor
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

    public struct Entry: Equatable, Hashable, Sendable {
        let pointer: GitPointer
        public let target: Object.ID
        public let name: String

        @GitActor
        init(pointer: GitPointer) throws {
            self.pointer = pointer

            target = try pointer.get(git_tree_entry_id)
                |> Unwrap
                |> \.pointee
                |> Object.ID.init

            name = try pointer.get(git_tree_entry_name) |> Unwrap |> String.init(cString:)
        }
    }
}

// MARK: - GitPointerInitialization

extension Tree: GitPointerInitialization {}
extension Tree.Entry: GitPointerInitialization {}
