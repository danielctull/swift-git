
import Cgit2

extension Repository {

    @GitActor
    public func blame(for path: FilePath) throws -> Blame {
        try path.rawValue.withCString { path in
            try Blame(
                create: pointer.create(git_blame_file, path, nil),
                free: git_blame_free)
        }
    }
}

// MARK: - Blame

public struct Blame: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Blame: CustomStringConvertible {
    public var description: String { "Blame" }
}

extension Blame {

    @GitActor
    public func hunk(for line: LineNumber) throws -> Hunk {
        try pointer.get(git_blame_get_hunk_byline, line.rawValue)
            |> Unwrap
            |> Hunk.init
    }

    public var hunks: [Hunk] {
        get throws {
            try GitCollection(
                pointer: pointer,
                count: git_blame_get_hunk_count,
                element: git_blame_get_hunk_byindex
            )
            .map(Unwrap)
            .map(\.pointee)
            .map(Hunk.init)
        }
    }
}

// MARK: - Blame.Hunk

extension Blame {

    public struct Hunk: Equatable, Sendable {
        public let lines: ClosedRange<LineNumber>
        public let signature: Signature
        public let commitID: Commit.ID
        public let path: FilePath
    }
}

extension Blame.Hunk {

    init(_ hunk: UnsafePointer<git_blame_hunk>) throws {
        try self.init(hunk.pointee)
    }

    init(_ hunk: git_blame_hunk) throws {
        lines = ClosedRange(start: hunk.final_start_line_number, count: hunk.lines_in_hunk)
        signature = try Signature(hunk.final_signature.pointee)
        commitID = Commit.ID(hunk.final_commit_id)
        path = hunk.orig_path |> String.init(cString:) |> FilePath.init(rawValue:)
    }
}

extension Blame.Hunk: CustomStringConvertible {

    public var description: String {
        "Blame.Hunk(path: \(self.path), lines: \(lines.shortDescription), commit: \(self.commitID.shortDescription))"
    }
}

// MARK: - GitPointerInitialization

extension Blame: GitPointerInitialization {}
