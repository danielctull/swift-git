
import Clibgit2

public struct Reflog {
    let reflog: GitPointer
}

extension Reflog {

    public struct Item: Equatable, Hashable, Identifiable {
        public let id: ID
        public var message: String { id.message }
        public var committer: Signature { id.committer }
        public var old: ObjectID { id.old }
        public var new: ObjectID { id.new }
    }

    public func items() throws -> [Item] {
        let count = reflog.get(git_reflog_entrycount)
        return try (0..<count).map { index in
            let pointer = try Unwrap(reflog.get { git_reflog_entry_byindex($0, index) })
            return Item(
                message: try Unwrap(String(validatingUTF8: git_reflog_entry_message(pointer))),
                committer: try Signature(Unwrap(git_reflog_entry_committer(pointer)).pointee),
                old: try ObjectID(Unwrap(git_reflog_entry_id_old(pointer)).pointee),
                new: try ObjectID(Unwrap(git_reflog_entry_id_new(pointer)).pointee)
            )
        }
    }
}

extension Reflog.Item {

    init(message: String, committer: Signature, old: ObjectID, new: ObjectID) {
        let id = ID(message: message, committer: committer, old: old, new: new)
        self.init(id: id)
    }

    public struct ID: Equatable, Hashable {
        let message: String
        let committer: Signature
        let old: ObjectID
        let new: ObjectID
    }
}
