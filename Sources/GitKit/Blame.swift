
import Clibgit2

extension Repository {

    public func blame(for path: FilePath) throws -> Blame {
        let blame = try GitPointer(
            create: repository.create(git_blame_file, path.rawValue, nil),
            free: git_blame_free)
        return try Blame(blame)
    }
}

// MARK: - Blame

public struct Blame {
    let blame: GitPointer
}

extension Blame {

    init(_ blame: GitPointer) throws {
        self.blame = blame
    }
}

extension Blame: CustomStringConvertible {
    public var description: String { "Blame" }
}

extension Blame {

    public func hunk(for line: LineNumber) throws -> Hunk {
        let hunk: git_blame_hunk = try blame.get { git_blame_get_hunk_byline($0, line.rawValue) }
        return try Hunk(hunk)
    }

    public var hunks: [Hunk] {
        get throws {
            try GitCollection(
                pointer: blame,
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

    public struct Hunk: Equatable {
        public let lines: ClosedRange<LineNumber>
        public let signature: Signature
        public let commitID: Commit.ID
        public let path: FilePath
    }
}

extension Blame.Hunk {

    init(_ hunk: git_blame_hunk) throws {
        lines = ClosedRange(start: hunk.final_start_line_number, count: hunk.lines_in_hunk)
        signature = try Signature(hunk.final_signature.pointee)
        commitID = Commit.ID(hunk.final_commit_id)
        path = try FilePath(rawValue: Unwrap(String(validatingUTF8: hunk.orig_path)))
    }
}

extension Blame.Hunk: CustomStringConvertible {

    public var description: String {
        "Blame.Hunk(path: \(self.path), lines: \(lines.shortDescription), commit: \(self.commitID.shortDescription))"
    }
}
