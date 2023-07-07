
import Clibgit2
import Tagged

extension Repository {

    @GitActor
    public func diff(from tree1: Tree, to tree2: Tree) throws -> Diff {
        try Diff(
            create: pointer.create(git_diff_tree_to_tree, tree1.pointer.pointer, tree2.pointer.pointer, nil),
            free: git_diff_free)
    }
}

// MARK: - Diff

public struct Diff: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Diff {

    public var deltas: [Delta] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_diff_num_deltas,
                element: git_diff_get_delta
            )
            .map(Unwrap)
            .map(\.pointee)
            .map(Delta.init)
        }
    }
}

// MARK: - Diff.Hunk

extension Diff {

    public struct Hunk {
        public let lines: ClosedRange<LineNumber>
        public let file: File
    }

    @GitActor
    public var hunks: [Hunk] {
        get throws {
            var hunks: [Hunk] = []

            try withUnsafeMutablePointer(to: &hunks) {
                try pointer.perform(git_diff_foreach, nil, nil, { delta, hunk, hunks in
                    GitError.catching {
                        let hunks = try Unwrap(hunks).assumingMemoryBound(to: [Hunk].self)
                        let delta = try Unwrap(delta?.pointee)
                        let hunk = try Unwrap(hunk?.pointee)
                        hunks.pointee.append(try Hunk(delta: delta, hunk: hunk))
                    }
                }, nil, $0)
            }

            return hunks
        }
    }
}

extension Diff.Hunk {

    fileprivate init(delta: git_diff_delta, hunk: git_diff_hunk) throws {
        let lines = ClosedRange(start: hunk.new_start, count: hunk.new_lines)
        let file = try Unwrap(Diff.File(delta.new_file))
        self.init(lines: lines, file: file)
    }
}

// MARK: - Diff.Delta

extension Diff {

    public struct Delta {
        public let status: Status
        public let from: File?
        public let to: File?
        public let flags: Flags
    }
}

extension Diff.Delta {

    init(_ delta: git_diff_delta) throws {
        flags = Diff.Flags(rawValue: delta.flags)
        from = try Diff.File(delta.old_file)
        to = try Diff.File(delta.new_file)
        status = try Diff.Delta.Status(status: delta.status, similarity: delta.similarity)
    }
}

// MARK: - Diff.Delta.Status

extension Diff.Delta {

    public enum Status: Equatable {
        case unmodified
        case added
        case deleted
        case modified
        case renamed(similarity: Int)
        case copied(similarity: Int)
        case ignored
        case untracked
        case typeChange
        case unreadable
        case conflicted
    }
}

extension Diff.Delta.Status {

    fileprivate init(status: git_delta_t, similarity: UInt16) throws {
        switch status {
        case GIT_DELTA_UNMODIFIED: self = .unmodified
        case GIT_DELTA_ADDED: self = .added
        case GIT_DELTA_DELETED: self = .deleted
        case GIT_DELTA_MODIFIED: self = .modified
        case GIT_DELTA_RENAMED: self = .renamed(similarity: Int(similarity))
        case GIT_DELTA_COPIED: self = .copied(similarity: Int(similarity))
        case GIT_DELTA_IGNORED: self = .ignored
        case GIT_DELTA_UNTRACKED: self = .untracked
        case GIT_DELTA_TYPECHANGE: self = .typeChange
        case GIT_DELTA_UNREADABLE: self = .unreadable
        case GIT_DELTA_CONFLICTED: self = .conflicted
        default:
            struct UnknownDeltaStatus: Error {}
            throw UnknownDeltaStatus()
        }
    }
}

// MARK: - Diff.File

extension Diff {

    public struct File: Identifiable, Sendable {
        public typealias ID = Tagged<File, Object.ID>
        public let id: ID
        public let path: String
        public let size: UInt64
        public let flags: Flags
    }
}

extension Diff.File {

    init?(_ file: git_diff_file) throws {
        flags = Diff.Flags(rawValue: file.flags)
        guard flags.contains(.exists) else { return nil }
        id = ID(oid: file.id)
        path = try Unwrap(String(validatingUTF8: file.path))
        size = file.size
    }
}

// MARK: - Diff.Status

extension Diff {

    public struct Status: OptionSet, Sendable {

        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        init(_ status: git_status_t) {
            self.init(rawValue: status.rawValue)
        }

        public static let current = Self(GIT_STATUS_CURRENT)

        public static let indexNew = Status(GIT_STATUS_INDEX_NEW)
        public static let indexModified = Status(GIT_STATUS_INDEX_MODIFIED)
        public static let indexDeleted = Status(GIT_STATUS_INDEX_DELETED)
        public static let indexRenamed = Status(GIT_STATUS_INDEX_RENAMED)
        public static let indexTypeChange = Status(GIT_STATUS_INDEX_TYPECHANGE)

        public static let workingTreeNew = Status(GIT_STATUS_WT_NEW)
        public static let workingTreeModified = Status(GIT_STATUS_WT_MODIFIED)
        public static let workingTreeDeleted = Status(GIT_STATUS_WT_DELETED)
        public static let workingTreeTypeChange = Status(GIT_STATUS_WT_TYPECHANGE)
        public static let workingTreeRenamed = Status(GIT_STATUS_WT_RENAMED)
        public static let workingTreeUnreadable = Status(GIT_STATUS_WT_UNREADABLE)

        public static let ignored = Self(GIT_STATUS_IGNORED)
        public static let conflicted = Self(GIT_STATUS_CONFLICTED)
    }
}

// MARK: - Diff.Flags

extension Diff {

    /// Flags for the delta object and the file objects on each side.
    ///
    /// These flags are used for both the `flags` values of `Diff.Delta` and
    /// `Diff.File` objects representing the old and new sides of the delta.
    public struct Flags: OptionSet, Sendable {

        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        private init(_ status: git_diff_flag_t) {
            self.init(rawValue: status.rawValue)
        }

        /// File(s) treated as binary data
        public static let binary = Self(GIT_DIFF_FLAG_BINARY)

        /// File(s) treated as text data
        public static let notBinary = Self(GIT_DIFF_FLAG_NOT_BINARY)

        /// `id` value is known correct
        public static let validID = Self(GIT_DIFF_FLAG_VALID_ID)

        /// File exists at this side of the delta
        public static let exists = Self(GIT_DIFF_FLAG_EXISTS)

        /// File size value is known correct
        public static let validSize = Self(GIT_DIFF_FLAG_VALID_SIZE)
    }
}

// MARK: - Diff.File.Mode

//    extension Diff.File {
//
//        public struct Mode: OptionSet {
//
//            public let rawValue: UInt16
//            public init(rawValue: UInt16) {
//                self.rawValue = rawValue
//            }
//
//            private init(_ mode: git_filemode_t) {
//                self.init(rawValue: mode.rawValue)
//            }
//
//            public static let unreadable = Self(GIT_FILEMODE_UNREADABLE)
//            public static let tree = Self(GIT_FILEMODE_TREE)
//            public static let blob = Self(GIT_FILEMODE_BLOB)
//            public static let blobExecutable = Self(GIT_FILEMODE_BLOB_EXECUTABLE)
//            public static let link = Self(GIT_FILEMODE_LINK)
//            public static let commit = Self(GIT_FILEMODE_COMMIT)
//        }
//    }

// MARK: - GitPointerInitialization

extension Diff: GitPointerInitialization {}
