
import Clibgit2

extension Repository {

    public var reflog: Reflog {
        get throws {
            let reflog = try GitPointer(
                create: repository.create(git_reflog_read, "HEAD"),
                free: git_reflog_free)
            return Reflog(reflog: reflog)
        }
    }
}

// MARK: - Reflog

@GitActor
public struct Reflog {
    let reflog: GitPointer
}

extension Reflog {

    public var items: [Item] {
        get throws {
            try GitCollection(
                pointer: reflog,
                count: git_reflog_entrycount,
                element: git_reflog_entry_byindex)
                .map(Reflog.Item.init)
        }
    }
}

// MARK: - Reflog.Item

extension Reflog {

    @GitActor
    public struct Item: Equatable, Hashable, Identifiable {
        public let id: ID
        public var message: String { id.message }
        public var committer: Signature { id.committer }
        public var old: Object.ID { id.old }
        public var new: Object.ID { id.new }
    }
}

extension Reflog.Item {

    fileprivate init(_ pointer: OpaquePointer?) throws {
        let pointer = try Unwrap(pointer)
        self.init(
            message: try Unwrap(String(validatingUTF8: git_reflog_entry_message(pointer))),
            committer: try Signature(Unwrap(git_reflog_entry_committer(pointer)).pointee),
            old: try Object.ID(Unwrap(git_reflog_entry_id_old(pointer)).pointee),
            new: try Object.ID(Unwrap(git_reflog_entry_id_new(pointer)).pointee))
    }
}

extension Reflog.Item {

    init(message: String, committer: Signature, old: Object.ID, new: Object.ID) {
        let id = ID(message: message, committer: committer, old: old, new: new)
        self.init(id: id)
    }
}

// MARK: - Reflog.Item.ID

extension Reflog.Item {

    public struct ID: Equatable, Hashable {
        let message: String
        let committer: Signature
        let old: Object.ID
        let new: Object.ID
    }
}
