
import Clibgit2

extension Repository {

    @GitActor
    public var status: [StatusEntry] {
        get throws {

            let list = try GitPointer(
                create: pointer.create(git_status_list_new, nil),
                free: git_status_list_free)

            return try GitCollection(
                pointer: list,
                count: git_status_list_entrycount,
                element: git_status_byindex)
            .map(StatusEntry.init)
        }
    }
}

// MARK: - StatusEntry

public struct StatusEntry {
    public let status: Diff.Status
    public let headToIndex: Diff.Delta?
    public let indexToWorkingDirectory: Diff.Delta?
}

extension StatusEntry {

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
