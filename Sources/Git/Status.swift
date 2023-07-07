
import Clibgit2

extension Repository {

    @GitActor
    public var status: Status {
        get throws {
            try Status(
                create: pointer.create(git_status_list_new, nil),
                free: git_status_list_free)
        }
    }
}

// MARK: - Status

public struct Status: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Status {

    public var entries: [Entry] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_status_list_entrycount,
                element: git_status_byindex)
            .map(Entry.init)
        }
    }
}

// MARK: - Status.Entry

extension Status {

    public struct Entry {
        public let status: Diff.Status
        public let headToIndex: Diff.Delta?
        public let indexToWorkingDirectory: Diff.Delta?
    }
}

extension Status.Entry {

    fileprivate init(_ pointer: UnsafePointer<git_status_entry>?) throws {
        let entry = try Unwrap(pointer).pointee
        status = Diff.Status(entry.status)
        if let head_to_index = entry.head_to_index {
            headToIndex = try Diff.Delta(head_to_index.pointee)
        } else {
            headToIndex = nil
        }
        if let index_to_workdir = entry.index_to_workdir {
            indexToWorkingDirectory = try Diff.Delta(index_to_workdir.pointee)
        } else {
            indexToWorkingDirectory = nil
        }
    }
}

// MARK: - GitPointerInitialization

extension Status: GitPointerInitialization {}
