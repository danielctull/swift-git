
import Clibgit2

extension Repository {

    @GitActor
    public var reflog: Reflog {
        get throws {
            try reflog(named: "HEAD")
        }
    }

    @GitActor
    public func reflog(named name: Reflog.Name) throws -> Reflog {
        try name.withCString { name in
            try Reflog(
                create: pointer.create(git_reflog_read, name),
                free: git_reflog_free)
        }
    }

    @GitActor
    public func renameReflog(from old: Reflog.Name, to new: Reflog.Name) throws {
        try old.withCString { old in
            try new.withCString { new in
                try pointer.perform(git_reflog_rename, old, new)
            }
        }
    }

    @GitActor
    public func deleteReflog(named name: Reflog.Name) throws {
        try name.withCString { name in
            try pointer.perform(git_reflog_delete, name)
        }
    }
}

// MARK: - Reflog

public struct Reflog: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Reflog {

    public var items: [Item] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_reflog_entrycount,
                element: git_reflog_entry_byindex)
                .map(Reflog.Item.init)
        }
    }

    /// Add a new entry to the in-memory reflog.
    ///
    /// To save the addition to disk, you should call ``write()``.
    ///
    /// - Parameters:
    ///   - id: The oid the reference is now pointing to.
    ///   - message: The reflog message.
    ///   - committer: The signature of the committer.
    @GitActor
    public func addItem(id: Object.ID, message: String, committer: Signature) throws {
        try id.withUnsafePointer { oid in
            try message.withCString { message in
                try committer.withUnsafePointer { committer in
                    try pointer.perform(git_reflog_append, oid, committer, message)
                }
            }
        }
    }

    /// Write the reflog back to disk using an atomic file lock.
    @GitActor
    public func write() throws {
        try pointer.perform(git_reflog_write)
    }
}

// MARK: - Reflog.Name

extension Reflog {

    public struct Name: Equatable, Hashable, Sendable {
        private let rawValue: String

        public init(_ string: some StringProtocol) {
            rawValue = String(string)
        }
    }
}

extension Reflog.Name: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Reflog.Name: CustomStringConvertible {

    public var description: String { rawValue }
}

extension Reflog.Name {

    fileprivate func withCString<Result>(
        _ body: (UnsafePointer<Int8>) throws -> Result
    ) rethrows -> Result {
        try rawValue.withCString(body)
    }
}

// MARK: - Reflog.Item

extension Reflog {

    public struct Item: Equatable, Hashable, Identifiable, Sendable {
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
            old: try Object.ID(oid: Unwrap(git_reflog_entry_id_old(pointer)).pointee),
            new: try Object.ID(oid: Unwrap(git_reflog_entry_id_new(pointer)).pointee))
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

    public struct ID: Equatable, Hashable, Sendable {
        let message: String
        let committer: Signature
        let old: Object.ID
        let new: Object.ID
    }
}

// MARK: - GitPointerInitialization

extension Reflog: GitPointerInitialization {}
