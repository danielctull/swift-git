
import Clibgit2
import Tagged

public struct Commit: Identifiable {
    let commit: GitPointer
    public typealias ID = Tagged<Commit, ObjectID>
    public let id: ID
    public let message: String
    public let author: Signature
    public let committer: Signature

    init(_ pointer: GitPointer) {
        commit = pointer
        id = ID(rawValue: ObjectID(commit.get(git_object_id)))
        message = String(validatingUTF8: commit.get(git_commit_message))!
        author = Signature(commit.get(git_commit_author))
        committer = Signature(commit.get(git_commit_committer))
    }
}
