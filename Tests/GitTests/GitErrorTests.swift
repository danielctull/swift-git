import Testing
import libgit2

@testable import Git

@Suite("GitError")
struct GitErrorTests {

  @Test func catching() {
    #expect(
      GitError.catching { throw GitError(code: .unknown) } == GIT_ERROR.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .notFound) }
        == GIT_ENOTFOUND.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .exists) }
        == GIT_EEXISTS.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .ambiguous) }
        == GIT_EAMBIGUOUS.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .buffer) } == GIT_EBUFS.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .user) } == GIT_EUSER.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .bareRepository) }
        == GIT_EBAREREPO.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .unbornBranch) }
        == GIT_EUNBORNBRANCH.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .unmerged) }
        == GIT_EUNMERGED.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .nonFastForward) }
        == GIT_ENONFASTFORWARD.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .invalidSpec) }
        == GIT_EINVALIDSPEC.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .conflict) }
        == GIT_ECONFLICT.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .locked) }
        == GIT_ELOCKED.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .modified) }
        == GIT_EMODIFIED.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .auth) } == GIT_EAUTH.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .certificate) }
        == GIT_ECERTIFICATE.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .applied) }
        == GIT_EAPPLIED.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .peel) } == GIT_EPEEL.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .endOfFile) }
        == GIT_EEOF.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .invalid) }
        == GIT_EINVALID.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .uncommitted) }
        == GIT_EUNCOMMITTED.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .directory) }
        == GIT_EDIRECTORY.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .mergeConflict) }
        == GIT_EMERGECONFLICT.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .passthrough) }
        == GIT_PASSTHROUGH.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .iteratorOver) }
        == GIT_ITEROVER.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .retry) } == GIT_RETRY.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .mismatch) }
        == GIT_EMISMATCH.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .indexDirty) }
        == GIT_EINDEXDIRTY.rawValue
    )
    #expect(
      GitError.catching { throw GitError(code: .applyFail) }
        == GIT_EAPPLYFAIL.rawValue
    )

    struct Failure: Error {}
    #expect(GitError.catching { throw Failure() } == GIT_EUSER.rawValue)
  }

  @Test func description() {
    #expect(
      GitError(domain: .none, code: .unknown, message: "message").description
        == "[None | Unknown] message"
    )
    #expect(
      GitError(domain: .noMemory, code: .notFound, message: "message")
        .description == "[No Memory | Not Found] message"
    )
    #expect(
      GitError(domain: .os, code: .exists, message: "message").description
        == "[OS | Exists] message"
    )
    #expect(
      GitError(domain: .invalid, code: .ambiguous, message: "message")
        .description == "[Invalid | Ambiguous] message"
    )
    #expect(
      GitError(domain: .reference, code: .buffer, message: "message")
        .description == "[Reference | Buffer] message"
    )
    #expect(
      GitError(domain: .zlib, code: .bareRepository, message: "message")
        .description == "[zlib | Bare Repository] message"
    )
    #expect(
      GitError(domain: .repository, code: .unbornBranch, message: "message")
        .description == "[Repository | Unborn Branch] message"
    )
    #expect(
      GitError(domain: .config, code: .unmerged, message: "message").description
        == "[Config | Unmerged] message"
    )
    #expect(
      GitError(domain: .regex, code: .nonFastForward, message: "message")
        .description == "[Regex | Non Fast-Forward] message"
    )
    #expect(
      GitError(domain: .odb, code: .invalidSpec, message: "message").description
        == "[ODB | Invalid Spec] message"
    )
    #expect(
      GitError(domain: .index, code: .conflict, message: "message").description
        == "[Index | Conflict] message"
    )
    #expect(
      GitError(domain: .object, code: .locked, message: "message").description
        == "[Object | Locked] message"
    )
    #expect(
      GitError(domain: .net, code: .modified, message: "message").description
        == "[Net | Modified] message"
    )
    #expect(
      GitError(domain: .tag, code: .auth, message: "message").description
        == "[Tag | Auth] message"
    )
    #expect(
      GitError(domain: .tree, code: .certificate, message: "message")
        .description == "[Tree | Certificate] message"
    )
    #expect(
      GitError(domain: .indexer, code: .applied, message: "message").description
        == "[Indexer | Applied] message"
    )
    #expect(
      GitError(domain: .ssl, code: .peel, message: "message").description
        == "[SSL | Peel] message"
    )
    #expect(
      GitError(domain: .submodule, code: .endOfFile, message: "message")
        .description == "[Submodule | End Of File] message"
    )
    #expect(
      GitError(domain: .thread, code: .invalid, message: "message").description
        == "[Thread | Invalid] message"
    )
    #expect(
      GitError(domain: .stash, code: .uncommitted, message: "message")
        .description == "[Stash | Uncommitted] message"
    )
    #expect(
      GitError(domain: .checkout, code: .directory, message: "message")
        .description == "[Checkout | Directory] message"
    )
    #expect(
      GitError(domain: .fetchHead, code: .mergeConflict, message: "message")
        .description == "[Fetch HEAD | Merge Conflict] message"
    )
    #expect(
      GitError(domain: .merge, code: .passthrough, message: "message")
        .description == "[Merge | Passthrough] message"
    )
    #expect(
      GitError(domain: .ssh, code: .iteratorOver, message: "message")
        .description == "[SSH | Iterator Over] message"
    )
    #expect(
      GitError(domain: .filter, code: .retry, message: "message").description
        == "[Filter | Retry] message"
    )
    #expect(
      GitError(domain: .revert, code: .mismatch, message: "message").description
        == "[Revert | Mismatch] message"
    )
    #expect(
      GitError(domain: .callback, code: .indexDirty, message: "message")
        .description == "[Callback | Index Dirty] message"
    )
    #expect(
      GitError(domain: .cherrypick, code: .applyFail, message: "message")
        .description == "[Cherrypick | Apply Fail] message"
    )
    #expect(
      GitError(domain: .describe, code: .unknown).description
        == "[Describe | Unknown] General error."
    )
    #expect(
      GitError(domain: .rebase, code: .notFound).description
        == "[Rebase | Not Found] Requested object could not be found."
    )
    #expect(
      GitError(domain: .filesystem, code: .exists).description
        == "[File System | Exists] Object exists preventing operation."
    )
    #expect(
      GitError(domain: .patch, code: .ambiguous).description
        == "[Patch | Ambiguous] More than one object matches."
    )
    #expect(
      GitError(domain: .worktree, code: .buffer).description
        == "[Worktree | Buffer] Output buffer too short to hold data."
    )
    #expect(
      GitError(domain: .sha, code: .bareRepository).description
        == "[SHA | Bare Repository] Operation not allowed on bare repository."
    )
    #expect(
      GitError(domain: .http, code: .unbornBranch).description
        == "[HTTP | Unborn Branch] HEAD refers to branch with no commits."
    )
    #expect(
      GitError(domain: .internal, code: .unmerged).description
        == "[Internal | Unmerged] Merge in progress prevented operation."
    )
  }

  @Test func domain() {
    #expect(GitError.Domain.none.description == "None")
    #expect(GitError.Domain.noMemory.description == "No Memory")
    #expect(GitError.Domain.os.description == "OS")
    #expect(GitError.Domain.invalid.description == "Invalid")
    #expect(GitError.Domain.reference.description == "Reference")
    #expect(GitError.Domain.zlib.description == "zlib")
    #expect(GitError.Domain.repository.description == "Repository")
    #expect(GitError.Domain.config.description == "Config")
    #expect(GitError.Domain.regex.description == "Regex")
    #expect(GitError.Domain.odb.description == "ODB")
    #expect(GitError.Domain.index.description == "Index")
    #expect(GitError.Domain.object.description == "Object")
    #expect(GitError.Domain.net.description == "Net")
    #expect(GitError.Domain.tag.description == "Tag")
    #expect(GitError.Domain.tree.description == "Tree")
    #expect(GitError.Domain.indexer.description == "Indexer")
    #expect(GitError.Domain.ssl.description == "SSL")
    #expect(GitError.Domain.submodule.description == "Submodule")
    #expect(GitError.Domain.thread.description == "Thread")
    #expect(GitError.Domain.stash.description == "Stash")
    #expect(GitError.Domain.checkout.description == "Checkout")
    #expect(GitError.Domain.fetchHead.description == "Fetch HEAD")
    #expect(GitError.Domain.merge.description == "Merge")
    #expect(GitError.Domain.ssh.description == "SSH")
    #expect(GitError.Domain.filter.description == "Filter")
    #expect(GitError.Domain.revert.description == "Revert")
    #expect(GitError.Domain.callback.description == "Callback")
    #expect(GitError.Domain.cherrypick.description == "Cherrypick")
    #expect(GitError.Domain.describe.description == "Describe")
    #expect(GitError.Domain.rebase.description == "Rebase")
    #expect(GitError.Domain.filesystem.description == "File System")
    #expect(GitError.Domain.patch.description == "Patch")
    #expect(GitError.Domain.worktree.description == "Worktree")
    #expect(GitError.Domain.sha.description == "SHA")
    #expect(GitError.Domain.http.description == "HTTP")
    #expect(GitError.Domain.internal.description == "Internal")
  }

  @Test func codeDescription() {
    #expect(GitError.Code.unknown.description == "Unknown")
    #expect(GitError.Code.notFound.description == "Not Found")
    #expect(GitError.Code.exists.description == "Exists")
    #expect(GitError.Code.ambiguous.description == "Ambiguous")
    #expect(GitError.Code.buffer.description == "Buffer")
    #expect(GitError.Code.bareRepository.description == "Bare Repository")
    #expect(GitError.Code.unbornBranch.description == "Unborn Branch")
    #expect(GitError.Code.unmerged.description == "Unmerged")
    #expect(GitError.Code.nonFastForward.description == "Non Fast-Forward")
    #expect(GitError.Code.invalidSpec.description == "Invalid Spec")
    #expect(GitError.Code.conflict.description == "Conflict")
    #expect(GitError.Code.locked.description == "Locked")
    #expect(GitError.Code.modified.description == "Modified")
    #expect(GitError.Code.auth.description == "Auth")
    #expect(GitError.Code.certificate.description == "Certificate")
    #expect(GitError.Code.applied.description == "Applied")
    #expect(GitError.Code.peel.description == "Peel")
    #expect(GitError.Code.endOfFile.description == "End Of File")
    #expect(GitError.Code.invalid.description == "Invalid")
    #expect(GitError.Code.uncommitted.description == "Uncommitted")
    #expect(GitError.Code.directory.description == "Directory")
    #expect(GitError.Code.mergeConflict.description == "Merge Conflict")
    #expect(GitError.Code.passthrough.description == "Passthrough")
    #expect(GitError.Code.iteratorOver.description == "Iterator Over")
    #expect(GitError.Code.retry.description == "Retry")
    #expect(GitError.Code.mismatch.description == "Mismatch")
    #expect(GitError.Code.indexDirty.description == "Index Dirty")
    #expect(GitError.Code.applyFail.description == "Apply Fail")
  }

  @Test func codeDetail() {
    #expect(GitError.Code.unknown.detail == "General error.")
    #expect(
      GitError.Code.notFound.detail == "Requested object could not be found."
    )
    #expect(
      GitError.Code.exists.detail == "Object exists preventing operation."
    )
    #expect(GitError.Code.ambiguous.detail == "More than one object matches.")
    #expect(
      GitError.Code.buffer.detail == "Output buffer too short to hold data."
    )
    #expect(
      GitError.Code.bareRepository.detail
        == "Operation not allowed on bare repository."
    )
    #expect(
      GitError.Code.unbornBranch.detail
        == "HEAD refers to branch with no commits."
    )
    #expect(
      GitError.Code.unmerged.detail == "Merge in progress prevented operation."
    )
    #expect(
      GitError.Code.nonFastForward.detail
        == "Reference was not fast-forwardable."
    )
    #expect(
      GitError.Code.invalidSpec.detail
        == "Name/ref spec was not in a valid format."
    )
    #expect(
      GitError.Code.conflict.detail == "Checkout conflicts prevented operation."
    )
    #expect(GitError.Code.locked.detail == "Lock file prevented operation.")
    #expect(
      GitError.Code.modified.detail
        == "Reference value does not match expected."
    )
    #expect(GitError.Code.auth.detail == "Authentication error.")
    #expect(
      GitError.Code.certificate.detail == "Server certificate is invalid."
    )
    #expect(
      GitError.Code.applied.detail == "Patch/merge has already been applied."
    )
    #expect(
      GitError.Code.peel.detail
        == "The requested peel operation is not possible."
    )
    #expect(GitError.Code.endOfFile.detail == "Unexpected end of file.")
    #expect(GitError.Code.invalid.detail == "Invalid operation or input.")
    #expect(
      GitError.Code.uncommitted.detail
        == "Uncommitted changes in index prevented operation."
    )
    #expect(
      GitError.Code.directory.detail
        == "The operation is not valid for a directory."
    )
    #expect(
      GitError.Code.mergeConflict.detail
        == "A merge conflict exists and cannot continue."
    )
    #expect(
      GitError.Code.passthrough.detail
        == "A user-configured callback refused to act."
    )
    #expect(
      GitError.Code.iteratorOver.detail
        == "Signals end of iteration with iterator."
    )
    #expect(GitError.Code.retry.detail == "Internal only.")
    #expect(GitError.Code.mismatch.detail == "Hashsum mismatch in object.")
    #expect(
      GitError.Code.indexDirty.detail
        == "Unsaved changes in the index would be overwritten."
    )
    #expect(GitError.Code.applyFail.detail == "Patch application failed.")
  }
}
