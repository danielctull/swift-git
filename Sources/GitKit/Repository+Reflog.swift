
import Clibgit2

extension Repository {

    public func reflog() throws -> Reflog {
        let reflog = try GitPointer(create: { git_reflog_read($0, repository.pointer, "HEAD") },
                                    free: git_reflog_free)
        return Reflog(reflog: reflog)
    }
}
