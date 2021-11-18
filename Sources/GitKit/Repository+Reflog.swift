
import Clibgit2

extension Repository {

    public func reflog() throws -> Reflog {
        let reflog = try GitPointer(create: repository.create(git_reflog_read, "HEAD"),
                                    free: git_reflog_free)
        return Reflog(reflog: reflog)
    }
}
