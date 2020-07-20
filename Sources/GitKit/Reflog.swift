
import Clibgit2

public struct Reflog {
    let reflog: GitPointer
}

extension Reflog {

    public struct Item: Equatable, Hashable {
        public let message: String
        public let committer: Signature
        public let old: ObjectID
        public let new: ObjectID
    }

    public var items: [Item] {
        let count = reflog.get(git_reflog_entrycount)
        return (0..<count).map { index in
            let pointer = reflog.get { git_reflog_entry_byindex($0, index) }!
            return Item(
                message: String(validatingUTF8: git_reflog_entry_message(pointer))!,
                committer: Signature(git_reflog_entry_committer(pointer)!.pointee),
                old: ObjectID(git_reflog_entry_id_old(pointer)!.pointee),
                new: ObjectID(git_reflog_entry_id_new(pointer)!.pointee)
            )
        }
    }
}

extension Reflog.Item: Identifiable {

    public var id: ID { ID(committer: committer, old: old, new: new) }

    public struct ID: Hashable, Equatable {
        public let committer: Signature
        public let old: ObjectID
        public let new: ObjectID
    }
}
