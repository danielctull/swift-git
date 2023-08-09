
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

    func testDescription() {
        XCTAssertEqual(GitError(.unknown).description, "[libgit2] Unknown")
        XCTAssertEqual(GitError(.notFound).description, "[libgit2] Not Found")
        XCTAssertEqual(GitError(.exists).description, "[libgit2] Exists")
        XCTAssertEqual(GitError(.ambiguous).description, "[libgit2] Ambiguous")
        XCTAssertEqual(GitError(.buffer).description, "[libgit2] Buffer")
        XCTAssertEqual(GitError(.bareRepository).description, "[libgit2] Bare Repository")
        XCTAssertEqual(GitError(.unbornBranch).description, "[libgit2] Unborn Branch")
        XCTAssertEqual(GitError(.unmerged).description, "[libgit2] Unmerged")
        XCTAssertEqual(GitError(.nonFastForward).description, "[libgit2] Non Fast-Forward")
        XCTAssertEqual(GitError(.invalidSpec).description, "[libgit2] Invalid Spec")
        XCTAssertEqual(GitError(.conflict).description, "[libgit2] Conflict")
        XCTAssertEqual(GitError(.locked).description, "[libgit2] Locked")
        XCTAssertEqual(GitError(.modified).description, "[libgit2] Modified")
        XCTAssertEqual(GitError(.auth).description, "[libgit2] Auth")
        XCTAssertEqual(GitError(.certificate).description, "[libgit2] Certificate")
        XCTAssertEqual(GitError(.applied).description, "[libgit2] Applied")
        XCTAssertEqual(GitError(.peel).description, "[libgit2] Peel")
        XCTAssertEqual(GitError(.endOfFile).description, "[libgit2] End Of File")
        XCTAssertEqual(GitError(.invalid).description, "[libgit2] Invalid")
        XCTAssertEqual(GitError(.uncommitted).description, "[libgit2] Uncommitted")
        XCTAssertEqual(GitError(.directory).description, "[libgit2] Directory")
        XCTAssertEqual(GitError(.mergeConflict).description, "[libgit2] Merge Conflict")
        XCTAssertEqual(GitError(.passthrough).description, "[libgit2] Passthrough")
        XCTAssertEqual(GitError(.iteratorOver).description, "[libgit2] Iterator Over")
        XCTAssertEqual(GitError(.retry).description, "[libgit2] Retry")
        XCTAssertEqual(GitError(.mismatch).description, "[libgit2] Mismatch")
        XCTAssertEqual(GitError(.indexDirty).description, "[libgit2] Index Dirty")
        XCTAssertEqual(GitError(.applyFail).description, "[libgit2] Apply Fail")
    }
}
