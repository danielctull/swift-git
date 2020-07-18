
import Clibgit2

public struct GitError: Error {
    public let code: Code

    init(_ code: Code) {
        self.code = code
    }
}

extension GitError {

    init?(_ result: Int32) {
        let code = git_error_code(result)
        guard code != GIT_OK else { return nil }
        self.init(Code(code: code))
    }
}

extension GitError {

    public struct Code {
        let code: git_error_code
    }
}

extension GitError.Code {

    /// Generic error
    public static let unknown = Self(code: GIT_ERROR)

    /// Requested object could not be found
    public static let notFound = Self(code: GIT_ENOTFOUND)

    /// Object exists preventing operation
    public static let exists = Self(code: GIT_EEXISTS)

    /// More than one object matches
    public static let ambiguous = Self(code: GIT_EAMBIGUOUS)

    /// Output buffer too short to hold data
    public static let buffer = Self(code: GIT_EBUFS)

    /// Operation not allowed on bare repository
    public static let bareRepository = Self(code: GIT_EBAREREPO)

    /// HEAD refers to branch with no commits
    public static let unbornBranch = Self(code: GIT_EUNBORNBRANCH)

    /// Merge in progress prevented operation
    public static let unmerged = Self(code: GIT_EUNMERGED)

    /// Reference was not fast-forwardable
    public static let nonFastForward = Self(code: GIT_ENONFASTFORWARD)

    /// Name/ref spec was not in a valid format
    public static let invalidSpec = Self(code: GIT_EINVALIDSPEC)

    /// Checkout conflicts prevented operation
    public static let conflict = Self(code: GIT_ECONFLICT)

    /// Lock file prevented operation
    public static let locked = Self(code: GIT_ELOCKED)

    /// Reference value does not match expected
    public static let modified = Self(code: GIT_EMODIFIED)

    /// Authentication error
    public static let auth = Self(code: GIT_EAUTH)

    /// Server certificate is invalid
    public static let certificate = Self(code: GIT_ECERTIFICATE)

    /// Patch/merge has already been applied
    public static let applied = Self(code: GIT_EAPPLIED)

    /// The requested peel operation is not possible
    public static let peel = Self(code: GIT_EPEEL)

    /// Unexpected EOF
    public static let endOfFile = Self(code: GIT_EEOF)

    /// Invalid operation or input
    public static let invalid = Self(code: GIT_EINVALID)

    /// Uncommitted changes in index prevented operation
    public static let uncommitted = Self(code: GIT_EUNCOMMITTED)

    /// The operation is not valid for a directory
    public static let directory = Self(code: GIT_EDIRECTORY)

    /// A merge conflict exists and cannot continue
    public static let mergeConflict = Self(code: GIT_EMERGECONFLICT)

    /// A user-configured callback refused to act
    public static let passthrough = Self(code: GIT_PASSTHROUGH)

    /// Signals end of iteration with iterator
    static let iteratorOver = Self(code: GIT_ITEROVER)

    /// Internal only
    static let retry = Self(code: GIT_RETRY)

    /// Hashsum mismatch in object
    public static let mismatch = Self(code: GIT_EMISMATCH)

    /// Unsaved changes in the index would be overwritten
    public static let indexDirty = Self(code: GIT_EINDEXDIRTY)

    /// Patch application failed
    public static let applyFail = Self(code: GIT_EAPPLYFAIL)
}
