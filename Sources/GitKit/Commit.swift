
import Clibgit2
import Tagged

public struct Commit: Identifiable {
    let commit: GitPointer
    public typealias ID = Tagged<Commit, ObjectID>
    public let id: ID
    public let summary: String
    public let author: Signature
    public let committer: Signature

    init(_ pointer: GitPointer) {
        commit = pointer
        id = ID(rawValue: ObjectID(commit.get(git_commit_id)))
        summary = String(validatingUTF8: commit.get(git_commit_summary))!
        author = Signature(commit.get(git_commit_author))
        committer = Signature(commit.get(git_commit_committer))
    }
}
