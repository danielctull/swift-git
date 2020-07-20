
import Clibgit2

public struct Commit {
    let commit: GitPointer
    public let objectID: ObjectID
    public let message: String

    init(_ pointer: GitPointer) {
        commit = pointer
        objectID = ObjectID(commit.get(git_object_id))
        message = String(validatingUTF8: commit.get(git_commit_message))!
    }
}
