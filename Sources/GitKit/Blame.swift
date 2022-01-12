
import Clibgit2

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

// MARK: - Blame.Hunk

extension Blame {

    public struct Hunk: Equatable {
        public let lines: ClosedRange<LineNumber>
        public let signature: Signature
        public let commitID: Commit.ID
        public let path: FilePath
    }

    public func hunk(for line: LineNumber) async throws -> Hunk {
        let hunk: git_blame_hunk = try await blame.get { git_blame_get_hunk_byline($0, line.rawValue) }
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
