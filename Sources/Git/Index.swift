
import Clibgit2

public struct Index: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Repository {

    @GitActor
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

    public var entries: [Entry] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_index_entrycount,
                element: git_index_get_byindex
            )
            .map(Unwrap)
            .map(\.pointee)
            .map(Entry.init)
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
