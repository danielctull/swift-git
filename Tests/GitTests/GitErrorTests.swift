
import Clibgit2
@testable import Git
import XCTest

final class GitErrorTests: XCTestCase {

    func testCatching() {
        XCTAssertEqual(GitError.catching { throw GitError(.unknown) }, GIT_ERROR.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.notFound) }, GIT_ENOTFOUND.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.exists) }, GIT_EEXISTS.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.ambiguous) }, GIT_EAMBIGUOUS.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.buffer) }, GIT_EBUFS.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.user) }, GIT_EUSER.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.bareRepository) }, GIT_EBAREREPO.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.unbornBranch) }, GIT_EUNBORNBRANCH.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.unmerged) }, GIT_EUNMERGED.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.nonFastForward) }, GIT_ENONFASTFORWARD.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.invalidSpec) }, GIT_EINVALIDSPEC.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.conflict) }, GIT_ECONFLICT.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.locked) }, GIT_ELOCKED.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.modified) }, GIT_EMODIFIED.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.auth) }, GIT_EAUTH.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.certificate) }, GIT_ECERTIFICATE.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.applied) }, GIT_EAPPLIED.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.peel) }, GIT_EPEEL.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.endOfFile) }, GIT_EEOF.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.invalid) }, GIT_EINVALID.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.uncommitted) }, GIT_EUNCOMMITTED.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.directory) }, GIT_EDIRECTORY.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.mergeConflict) }, GIT_EMERGECONFLICT.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.passthrough) }, GIT_PASSTHROUGH.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.iteratorOver) }, GIT_ITEROVER.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.retry) }, GIT_RETRY.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.mismatch) }, GIT_EMISMATCH.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.indexDirty) }, GIT_EINDEXDIRTY.rawValue)
        XCTAssertEqual(GitError.catching { throw GitError(.applyFail) }, GIT_EAPPLYFAIL.rawValue)

        struct Failure: Error {}
        XCTAssertEqual(GitError.catching { throw Failure() }, GIT_EUSER.rawValue)
    }

    func testDomain() {
        XCTAssertEqual(GitError.Domain.none.description, "None")
        XCTAssertEqual(GitError.Domain.noMemory.description, "No Memory")
        XCTAssertEqual(GitError.Domain.os.description, "OS")
        XCTAssertEqual(GitError.Domain.invalid.description, "Invalid")
        XCTAssertEqual(GitError.Domain.reference.description, "Reference")
        XCTAssertEqual(GitError.Domain.zlib.description, "zlib")
        XCTAssertEqual(GitError.Domain.repository.description, "Repository")
        XCTAssertEqual(GitError.Domain.config.description, "Config")
        XCTAssertEqual(GitError.Domain.regex.description, "Regex")
        XCTAssertEqual(GitError.Domain.odb.description, "ODB")
        XCTAssertEqual(GitError.Domain.index.description, "Index")
        XCTAssertEqual(GitError.Domain.object.description, "Object")
        XCTAssertEqual(GitError.Domain.net.description, "Net")
        XCTAssertEqual(GitError.Domain.tag.description, "Tag")
        XCTAssertEqual(GitError.Domain.tree.description, "Tree")
        XCTAssertEqual(GitError.Domain.indexer.description, "Indexer")
        XCTAssertEqual(GitError.Domain.ssl.description, "SSL")
        XCTAssertEqual(GitError.Domain.submodule.description, "Submodule")
        XCTAssertEqual(GitError.Domain.thread.description, "Thread")
        XCTAssertEqual(GitError.Domain.stash.description, "Stash")
        XCTAssertEqual(GitError.Domain.checkout.description, "Checkout")
        XCTAssertEqual(GitError.Domain.fetchhead.description, "Fetch HEAD")
        XCTAssertEqual(GitError.Domain.merge.description, "Merge")
        XCTAssertEqual(GitError.Domain.ssh.description, "SSH")
        XCTAssertEqual(GitError.Domain.filter.description, "Filter")
        XCTAssertEqual(GitError.Domain.revert.description, "Revert")
        XCTAssertEqual(GitError.Domain.callback.description, "Callback")
        XCTAssertEqual(GitError.Domain.cherrypick.description, "Cherrypick")
        XCTAssertEqual(GitError.Domain.describe.description, "Describe")
        XCTAssertEqual(GitError.Domain.rebase.description, "Rebase")
        XCTAssertEqual(GitError.Domain.filesystem.description, "File System")
        XCTAssertEqual(GitError.Domain.patch.description, "Patch")
        XCTAssertEqual(GitError.Domain.worktree.description, "Worktree")
        XCTAssertEqual(GitError.Domain.sha.description, "SHA")
        XCTAssertEqual(GitError.Domain.http.description, "HTTP")
        XCTAssertEqual(GitError.Domain.internal.description, "Internal")
    }

    func testCode() {
        XCTAssertEqual(GitError.Code.unknown.description, "Unknown")
        XCTAssertEqual(GitError.Code.notFound.description, "Not Found")
        XCTAssertEqual(GitError.Code.exists.description, "Exists")
        XCTAssertEqual(GitError.Code.ambiguous.description, "Ambiguous")
        XCTAssertEqual(GitError.Code.buffer.description, "Buffer")
        XCTAssertEqual(GitError.Code.bareRepository.description, "Bare Repository")
        XCTAssertEqual(GitError.Code.unbornBranch.description, "Unborn Branch")
        XCTAssertEqual(GitError.Code.unmerged.description, "Unmerged")
        XCTAssertEqual(GitError.Code.nonFastForward.description, "Non Fast-Forward")
        XCTAssertEqual(GitError.Code.invalidSpec.description, "Invalid Spec")
        XCTAssertEqual(GitError.Code.conflict.description, "Conflict")
        XCTAssertEqual(GitError.Code.locked.description, "Locked")
        XCTAssertEqual(GitError.Code.modified.description, "Modified")
        XCTAssertEqual(GitError.Code.auth.description, "Auth")
        XCTAssertEqual(GitError.Code.certificate.description, "Certificate")
        XCTAssertEqual(GitError.Code.applied.description, "Applied")
        XCTAssertEqual(GitError.Code.peel.description, "Peel")
        XCTAssertEqual(GitError.Code.endOfFile.description, "End Of File")
        XCTAssertEqual(GitError.Code.invalid.description, "Invalid")
        XCTAssertEqual(GitError.Code.uncommitted.description, "Uncommitted")
        XCTAssertEqual(GitError.Code.directory.description, "Directory")
        XCTAssertEqual(GitError.Code.mergeConflict.description, "Merge Conflict")
        XCTAssertEqual(GitError.Code.passthrough.description, "Passthrough")
        XCTAssertEqual(GitError.Code.iteratorOver.description, "Iterator Over")
        XCTAssertEqual(GitError.Code.retry.description, "Retry")
        XCTAssertEqual(GitError.Code.mismatch.description, "Mismatch")
        XCTAssertEqual(GitError.Code.indexDirty.description, "Index Dirty")
        XCTAssertEqual(GitError.Code.applyFail.description, "Apply Fail")
    }
}
