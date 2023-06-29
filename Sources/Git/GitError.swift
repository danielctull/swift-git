
import Clibgit2

public struct GitError: Error, Equatable {
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

    static func check(_ result: Int32) throws {
        let code = git_error_code(result)
        if code != GIT_OK { throw Self(Code(code: code)) }
    }
}

extension GitError {

    public struct Code {
        let code: git_error_code
        fileprivate init(code: git_error_code) {
            self.code = code
        }
    }
}

extension GitError {

    /// This runs a throwing function and translates thrown errors to the error
    /// codes expected by libgit2.
    ///
    /// This is useful for callback functions, where we want to use usual Swift
    /// error throwing, but the library only wants the raw code returned.
    ///
    /// If a ``GitError`` is thrown, its error code will be used as the return,
    /// otherwise ``GitError.unknown`` will be used.
    ///
    /// - Parameter f: A throwing function.
    /// - Returns: The libgit raw error code.
    static func catching(_ f: () throws -> Void) -> Int32 {
        do {
            try f()
            return GIT_OK.rawValue
        } catch let error as GitError {
            return error.code.code.rawValue
        } catch {
            return GitError.Code.unknown.code.rawValue
        }
    }
}

extension GitError.Code: Equatable {

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

extension GitError: CustomStringConvertible {

    public var description: String {
        switch code {
        case .unknown: return "[libgit2] Unknown"
        case .notFound: return "[libgit2] Not Found"
        case .exists: return "[libgit2] Exists"
        case .ambiguous: return "[libgit2] Ambiguous"
        case .buffer: return "[libgit2] Buffer"
        case .bareRepository: return "[libgit2] Bare Repository"
        case .unbornBranch: return "[libgit2] Unborn Branch"
        case .unmerged: return "[libgit2] Unmerged"
        case .nonFastForward: return "[libgit2] Non Fast-Forward"
        case .invalidSpec: return "[libgit2] Invalid Spec"
        case .conflict: return "[libgit2] Conflict"
        case .locked: return "[libgit2] Locked"
        case .modified: return "[libgit2] Modified"
        case .auth: return "[libgit2] Auth"
        case .certificate: return "[libgit2] Certificate"
        case .applied: return "[libgit2] Applied"
        case .peel: return "[libgit2] Peel"
        case .endOfFile: return "[libgit2] End Of File"
        case .invalid: return "[libgit2] Invalid"
        case .uncommitted: return "[libgit2] Uncommitted"
        case .directory: return "[libgit2] Directory"
        case .mergeConflict: return "[libgit2] Merge Conflict"
        case .passthrough: return "[libgit2] Passthrough"
        case .iteratorOver: return "[libgit2] Iterator Over"
        case .retry: return "[libgit2] Retry"
        case .mismatch: return "[libgit2] Mismatch"
        case .indexDirty: return "[libgit2] Index Dirty"
        case .applyFail: return "[libgit2] Apply Fail"
        default: return "Who knows?"
        }
    }
}
