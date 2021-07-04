
import Cgit2

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

    public func hunk(for line: LineNumber) throws -> Hunk {
        let hunk: git_blame_hunk = try blame.get { git_blame_get_hunk_byline($0, line.rawValue) }
        return try Hunk(hunk)
    }

    public func hunks() throws -> [Hunk] {
        let count = blame.get(git_blame_get_hunk_count)
        return try (0..<count).map { index in
            let hunk = try Unwrap(git_blame_get_hunk_byindex(blame.pointer, index))
            return try Hunk(hunk.pointee)
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
