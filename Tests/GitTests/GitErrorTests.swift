import Testing
import libgit2

@testable import Git

final class GitErrorTests: XCTestCase {

  func testCatching() {
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .unknown) },
      GIT_ERROR.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .notFound) },
      GIT_ENOTFOUND.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .exists) },
      GIT_EEXISTS.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .ambiguous) },
      GIT_EAMBIGUOUS.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .buffer) },
      GIT_EBUFS.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .user) },
      GIT_EUSER.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .bareRepository) },
      GIT_EBAREREPO.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .unbornBranch) },
      GIT_EUNBORNBRANCH.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .unmerged) },
      GIT_EUNMERGED.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .nonFastForward) },
      GIT_ENONFASTFORWARD.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .invalidSpec) },
      GIT_EINVALIDSPEC.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .conflict) },
      GIT_ECONFLICT.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .locked) },
      GIT_ELOCKED.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .modified) },
      GIT_EMODIFIED.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .auth) },
      GIT_EAUTH.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .certificate) },
      GIT_ECERTIFICATE.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .applied) },
      GIT_EAPPLIED.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .peel) },
      GIT_EPEEL.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .endOfFile) },
      GIT_EEOF.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .invalid) },
      GIT_EINVALID.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .uncommitted) },
      GIT_EUNCOMMITTED.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .directory) },
      GIT_EDIRECTORY.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .mergeConflict) },
      GIT_EMERGECONFLICT.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .passthrough) },
      GIT_PASSTHROUGH.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .iteratorOver) },
      GIT_ITEROVER.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .retry) },
      GIT_RETRY.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .mismatch) },
      GIT_EMISMATCH.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .indexDirty) },
      GIT_EINDEXDIRTY.rawValue
    )
    XCTAssertEqual(
      GitError.catching { throw GitError(code: .applyFail) },
      GIT_EAPPLYFAIL.rawValue
    )

    struct Failure: Error {}
    XCTAssertEqual(GitError.catching { throw Failure() }, GIT_EUSER.rawValue)
  }

  func testDescription() {
    XCTAssertEqual(
      GitError(domain: .none, code: .unknown, message: "message").description,
      "[None | Unknown] message"
    )
    XCTAssertEqual(
      GitError(domain: .noMemory, code: .notFound, message: "message")
        .description,
      "[No Memory | Not Found] message"
    )
    XCTAssertEqual(
      GitError(domain: .os, code: .exists, message: "message").description,
      "[OS | Exists] message"
    )
    XCTAssertEqual(
      GitError(domain: .invalid, code: .ambiguous, message: "message")
        .description,
      "[Invalid | Ambiguous] message"
    )
    XCTAssertEqual(
      GitError(domain: .reference, code: .buffer, message: "message")
        .description,
      "[Reference | Buffer] message"
    )
    XCTAssertEqual(
      GitError(domain: .zlib, code: .bareRepository, message: "message")
        .description,
      "[zlib | Bare Repository] message"
    )
    XCTAssertEqual(
      GitError(domain: .repository, code: .unbornBranch, message: "message")
        .description,
      "[Repository | Unborn Branch] message"
    )
    XCTAssertEqual(
      GitError(domain: .config, code: .unmerged, message: "message")
        .description,
      "[Config | Unmerged] message"
    )
    XCTAssertEqual(
      GitError(domain: .regex, code: .nonFastForward, message: "message")
        .description,
      "[Regex | Non Fast-Forward] message"
    )
    XCTAssertEqual(
      GitError(domain: .odb, code: .invalidSpec, message: "message")
        .description,
      "[ODB | Invalid Spec] message"
    )
    XCTAssertEqual(
      GitError(domain: .index, code: .conflict, message: "message").description,
      "[Index | Conflict] message"
    )
    XCTAssertEqual(
      GitError(domain: .object, code: .locked, message: "message").description,
      "[Object | Locked] message"
    )
    XCTAssertEqual(
      GitError(domain: .net, code: .modified, message: "message").description,
      "[Net | Modified] message"
    )
    XCTAssertEqual(
      GitError(domain: .tag, code: .auth, message: "message").description,
      "[Tag | Auth] message"
    )
    XCTAssertEqual(
      GitError(domain: .tree, code: .certificate, message: "message")
        .description,
      "[Tree | Certificate] message"
    )
    XCTAssertEqual(
      GitError(domain: .indexer, code: .applied, message: "message")
        .description,
      "[Indexer | Applied] message"
    )
    XCTAssertEqual(
      GitError(domain: .ssl, code: .peel, message: "message").description,
      "[SSL | Peel] message"
    )
    XCTAssertEqual(
      GitError(domain: .submodule, code: .endOfFile, message: "message")
        .description,
      "[Submodule | End Of File] message"
    )
    XCTAssertEqual(
      GitError(domain: .thread, code: .invalid, message: "message").description,
      "[Thread | Invalid] message"
    )
    XCTAssertEqual(
      GitError(domain: .stash, code: .uncommitted, message: "message")
        .description,
      "[Stash | Uncommitted] message"
    )
    XCTAssertEqual(
      GitError(domain: .checkout, code: .directory, message: "message")
        .description,
      "[Checkout | Directory] message"
    )
    XCTAssertEqual(
      GitError(domain: .fetchHead, code: .mergeConflict, message: "message")
        .description,
      "[Fetch HEAD | Merge Conflict] message"
    )
    XCTAssertEqual(
      GitError(domain: .merge, code: .passthrough, message: "message")
        .description,
      "[Merge | Passthrough] message"
    )
    XCTAssertEqual(
      GitError(domain: .ssh, code: .iteratorOver, message: "message")
        .description,
      "[SSH | Iterator Over] message"
    )
    XCTAssertEqual(
      GitError(domain: .filter, code: .retry, message: "message").description,
      "[Filter | Retry] message"
    )
    XCTAssertEqual(
      GitError(domain: .revert, code: .mismatch, message: "message")
        .description,
      "[Revert | Mismatch] message"
    )
    XCTAssertEqual(
      GitError(domain: .callback, code: .indexDirty, message: "message")
        .description,
      "[Callback | Index Dirty] message"
    )
    XCTAssertEqual(
      GitError(domain: .cherrypick, code: .applyFail, message: "message")
        .description,
      "[Cherrypick | Apply Fail] message"
    )
    XCTAssertEqual(
      GitError(domain: .describe, code: .unknown).description,
      "[Describe | Unknown] General error."
    )
    XCTAssertEqual(
      GitError(domain: .rebase, code: .notFound).description,
      "[Rebase | Not Found] Requested object could not be found."
    )
    XCTAssertEqual(
      GitError(domain: .filesystem, code: .exists).description,
      "[File System | Exists] Object exists preventing operation."
    )
    XCTAssertEqual(
      GitError(domain: .patch, code: .ambiguous).description,
      "[Patch | Ambiguous] More than one object matches."
    )
    XCTAssertEqual(
      GitError(domain: .worktree, code: .buffer).description,
      "[Worktree | Buffer] Output buffer too short to hold data."
    )
    XCTAssertEqual(
      GitError(domain: .sha, code: .bareRepository).description,
      "[SHA | Bare Repository] Operation not allowed on bare repository."
    )
    XCTAssertEqual(
      GitError(domain: .http, code: .unbornBranch).description,
      "[HTTP | Unborn Branch] HEAD refers to branch with no commits."
    )
    XCTAssertEqual(
      GitError(domain: .internal, code: .unmerged).description,
      "[Internal | Unmerged] Merge in progress prevented operation."
    )
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
    XCTAssertEqual(GitError.Domain.fetchHead.description, "Fetch HEAD")
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

  func testCodeDescription() {
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

  func testCodeDetail() {
    XCTAssertEqual(GitError.Code.unknown.detail, "General error.")
    XCTAssertEqual(
      GitError.Code.notFound.detail,
      "Requested object could not be found."
    )
    XCTAssertEqual(
      GitError.Code.exists.detail,
      "Object exists preventing operation."
    )
    XCTAssertEqual(
      GitError.Code.ambiguous.detail,
      "More than one object matches."
    )
    XCTAssertEqual(
      GitError.Code.buffer.detail,
      "Output buffer too short to hold data."
    )
    XCTAssertEqual(
      GitError.Code.bareRepository.detail,
      "Operation not allowed on bare repository."
    )
    XCTAssertEqual(
      GitError.Code.unbornBranch.detail,
      "HEAD refers to branch with no commits."
    )
    XCTAssertEqual(
      GitError.Code.unmerged.detail,
      "Merge in progress prevented operation."
    )
    XCTAssertEqual(
      GitError.Code.nonFastForward.detail,
      "Reference was not fast-forwardable."
    )
    XCTAssertEqual(
      GitError.Code.invalidSpec.detail,
      "Name/ref spec was not in a valid format."
    )
    XCTAssertEqual(
      GitError.Code.conflict.detail,
      "Checkout conflicts prevented operation."
    )
    XCTAssertEqual(
      GitError.Code.locked.detail,
      "Lock file prevented operation."
    )
    XCTAssertEqual(
      GitError.Code.modified.detail,
      "Reference value does not match expected."
    )
    XCTAssertEqual(GitError.Code.auth.detail, "Authentication error.")
    XCTAssertEqual(
      GitError.Code.certificate.detail,
      "Server certificate is invalid."
    )
    XCTAssertEqual(
      GitError.Code.applied.detail,
      "Patch/merge has already been applied."
    )
    XCTAssertEqual(
      GitError.Code.peel.detail,
      "The requested peel operation is not possible."
    )
    XCTAssertEqual(GitError.Code.endOfFile.detail, "Unexpected end of file.")
    XCTAssertEqual(GitError.Code.invalid.detail, "Invalid operation or input.")
    XCTAssertEqual(
      GitError.Code.uncommitted.detail,
      "Uncommitted changes in index prevented operation."
    )
    XCTAssertEqual(
      GitError.Code.directory.detail,
      "The operation is not valid for a directory."
    )
    XCTAssertEqual(
      GitError.Code.mergeConflict.detail,
      "A merge conflict exists and cannot continue."
    )
    XCTAssertEqual(
      GitError.Code.passthrough.detail,
      "A user-configured callback refused to act."
    )
    XCTAssertEqual(
      GitError.Code.iteratorOver.detail,
      "Signals end of iteration with iterator."
    )
    XCTAssertEqual(GitError.Code.retry.detail, "Internal only.")
    XCTAssertEqual(GitError.Code.mismatch.detail, "Hashsum mismatch in object.")
    XCTAssertEqual(
      GitError.Code.indexDirty.detail,
      "Unsaved changes in the index would be overwritten."
    )
    XCTAssertEqual(GitError.Code.applyFail.detail, "Patch application failed.")
  }
}
