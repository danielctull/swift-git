
import Clibgit2

extension Repository {

    public var reflog: Reflog {
        get throws {
            let reflog = try GitPointer(
                create: repository.create(git_reflog_read, "HEAD"),
                free: git_reflog_free)
            return Reflog(reflog: reflog)
        }
    }
}
