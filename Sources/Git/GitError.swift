
import Clibgit2

public struct GitError: Error, Equatable {

    public let domain: Domain
    public let code: Code
    public let message: String

    init(domain: Domain = .none, code: Code, message: String) {
        self.domain = domain
        self.code = code
        self.message = message
    }

    init(domain: Domain = .none, code: Code) {
        self.domain = domain
        self.code = code
        self.message = code.detail
    }
}

extension GitError: CustomStringConvertible {

    public var description: String {
        "[\(domain) | \(code)] \(message)"
    }
}

extension GitError {

    static func check(_ result: Int32) throws {
        let code = git_error_code(result)
        guard code != GIT_OK else { return }

        guard let error = try? git_error_last() |> Unwrap |> \.pointee else {
            throw GitError(code: Code(code))
        }

        throw GitError(
            domain: Domain(git_error_t(UInt32(error.klass))),
            code: Code(code),
            message: String(cString: error.message))
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
            return error.code.rawValue.rawValue
        } catch {
            return GitError.Code.user.rawValue.rawValue
        }
    }
}

// MARK: - GitError.Domain

extension GitError {
    public struct Domain: Equatable {
        fileprivate let rawValue: git_error_t
        fileprivate init(_ rawValue: git_error_t) {
            self.rawValue = rawValue
        }
    }
}

extension GitError.Domain {
    public static let none = Self(GIT_ERROR_NONE)
    public static let noMemory = Self(GIT_ERROR_NOMEMORY)
    public static let os = Self(GIT_ERROR_OS)
    public static let invalid = Self(GIT_ERROR_INVALID)
    public static let reference = Self(GIT_ERROR_REFERENCE)
    public static let zlib = Self(GIT_ERROR_ZLIB)
    public static let repository = Self(GIT_ERROR_REPOSITORY)
    public static let config = Self(GIT_ERROR_CONFIG)
    public static let regex = Self(GIT_ERROR_REGEX)
    public static let odb = Self(GIT_ERROR_ODB)
    public static let index = Self(GIT_ERROR_INDEX)
    public static let object = Self(GIT_ERROR_OBJECT)
    public static let net = Self(GIT_ERROR_NET)
    public static let tag = Self(GIT_ERROR_TAG)
    public static let tree = Self(GIT_ERROR_TREE)
    public static let indexer = Self(GIT_ERROR_INDEXER)
    public static let ssl = Self(GIT_ERROR_SSL)
    public static let submodule = Self(GIT_ERROR_SUBMODULE)
    public static let thread = Self(GIT_ERROR_THREAD)
    public static let stash = Self(GIT_ERROR_STASH)
    public static let checkout = Self(GIT_ERROR_CHECKOUT)
    public static let fetchhead = Self(GIT_ERROR_FETCHHEAD)
    public static let merge = Self(GIT_ERROR_MERGE)
    public static let ssh = Self(GIT_ERROR_SSH)
    public static let filter = Self(GIT_ERROR_FILTER)
    public static let revert = Self(GIT_ERROR_REVERT)
    public static let callback = Self(GIT_ERROR_CALLBACK)
    public static let cherrypick = Self(GIT_ERROR_CHERRYPICK)
    public static let describe = Self(GIT_ERROR_DESCRIBE)
    public static let rebase = Self(GIT_ERROR_REBASE)
    public static let filesystem = Self(GIT_ERROR_FILESYSTEM)
    public static let patch = Self(GIT_ERROR_PATCH)
    public static let worktree = Self(GIT_ERROR_WORKTREE)
    public static let sha = Self(GIT_ERROR_SHA)
    public static let http = Self(GIT_ERROR_HTTP)
    public static let `internal` = Self(GIT_ERROR_INTERNAL)
}

extension GitError.Domain: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none: return "None"
        case .noMemory: return "No Memory"
        case .os: return "OS"
        case .invalid: return "Invalid"
        case .reference: return "Reference"
        case .zlib: return "zlib"
        case .repository: return "Repository"
        case .config: return "Config"
        case .regex: return "Regex"
        case .odb: return "ODB"
        case .index: return "Index"
        case .object: return "Object"
        case .net: return "Net"
        case .tag: return "Tag"
        case .tree: return "Tree"
        case .indexer: return "Indexer"
        case .ssl: return "SSL"
        case .submodule: return "Submodule"
        case .thread: return "Thread"
        case .stash: return "Stash"
        case .checkout: return "Checkout"
        case .fetchhead: return "Fetch HEAD"
        case .merge: return "Merge"
        case .ssh: return "SSH"
        case .filter: return "Filter"
        case .revert: return "Revert"
        case .callback: return "Callback"
        case .cherrypick: return "Cherrypick"
        case .describe: return "Describe"
        case .rebase: return "Rebase"
        case .filesystem: return "File System"
        case .patch: return "Patch"
        case .worktree: return "Worktree"
        case .sha: return "SHA"
        case .http: return "HTTP"
        case .internal: return "Internal"
        default: return "Unknown"
        }
    }
}

// MARK: - GitError.Code

extension GitError {

    public struct Code: Equatable {
        fileprivate let rawValue: git_error_code
        fileprivate init(_ rawValue: git_error_code) {
            self.rawValue = rawValue
        }
    }
}

extension GitError.Code {

    /// Generic error
    public static let unknown = Self(GIT_ERROR)

    /// Requested object could not be found
    public static let notFound = Self(GIT_ENOTFOUND)

    /// Object exists preventing operation
    public static let exists = Self(GIT_EEXISTS)

    /// More than one object matches
    public static let ambiguous = Self(GIT_EAMBIGUOUS)

    /// Output buffer too short to hold data
    public static let buffer = Self(GIT_EBUFS)

    // A special error that is never generated by libgit2 code.
    //
    // This can be returned from a callback (e.g to stop an iteration) to show
    // it was generated by the callback and not by libgit2.
    static let user = Self(GIT_EUSER)

    /// Operation not allowed on bare repository
    public static let bareRepository = Self(GIT_EBAREREPO)

    /// HEAD refers to branch with no commits
    public static let unbornBranch = Self(GIT_EUNBORNBRANCH)

    /// Merge in progress prevented operation
    public static let unmerged = Self(GIT_EUNMERGED)

    /// Reference was not fast-forwardable
    public static let nonFastForward = Self(GIT_ENONFASTFORWARD)

    /// Name/ref spec was not in a valid format
    public static let invalidSpec = Self(GIT_EINVALIDSPEC)

    /// Checkout conflicts prevented operation
    public static let conflict = Self(GIT_ECONFLICT)

    /// Lock file prevented operation
    public static let locked = Self(GIT_ELOCKED)

    /// Reference value does not match expected
    public static let modified = Self(GIT_EMODIFIED)

    /// Authentication error
    public static let auth = Self(GIT_EAUTH)

    /// Server certificate is invalid
    public static let certificate = Self(GIT_ECERTIFICATE)

    /// Patch/merge has already been applied
    public static let applied = Self(GIT_EAPPLIED)

    /// The requested peel operation is not possible
    public static let peel = Self(GIT_EPEEL)

    /// Unexpected EOF
    public static let endOfFile = Self(GIT_EEOF)

    /// Invalid operation or input
    public static let invalid = Self(GIT_EINVALID)

    /// Uncommitted changes in index prevented operation
    public static let uncommitted = Self(GIT_EUNCOMMITTED)

    /// The operation is not valid for a directory
    public static let directory = Self(GIT_EDIRECTORY)

    /// A merge conflict exists and cannot continue
    public static let mergeConflict = Self(GIT_EMERGECONFLICT)

    /// A user-configured callback refused to act
    public static let passthrough = Self(GIT_PASSTHROUGH)

    /// Signals end of iteration with iterator
    static let iteratorOver = Self(GIT_ITEROVER)

    /// Internal only
    static let retry = Self(GIT_RETRY)

    /// Hashsum mismatch in object
    public static let mismatch = Self(GIT_EMISMATCH)

    /// Unsaved changes in the index would be overwritten
    public static let indexDirty = Self(GIT_EINDEXDIRTY)

    /// Patch application failed
    public static let applyFail = Self(GIT_EAPPLYFAIL)
}

extension GitError.Code: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .notFound: return "Not Found"
        case .exists: return "Exists"
        case .ambiguous: return "Ambiguous"
        case .buffer: return "Buffer"
        case .bareRepository: return "Bare Repository"
        case .unbornBranch: return "Unborn Branch"
        case .unmerged: return "Unmerged"
        case .nonFastForward: return "Non Fast-Forward"
        case .invalidSpec: return "Invalid Spec"
        case .conflict: return "Conflict"
        case .locked: return "Locked"
        case .modified: return "Modified"
        case .auth: return "Auth"
        case .certificate: return "Certificate"
        case .applied: return "Applied"
        case .peel: return "Peel"
        case .endOfFile: return "End Of File"
        case .invalid: return "Invalid"
        case .uncommitted: return "Uncommitted"
        case .directory: return "Directory"
        case .mergeConflict: return "Merge Conflict"
        case .passthrough: return "Passthrough"
        case .iteratorOver: return "Iterator Over"
        case .retry: return "Retry"
        case .mismatch: return "Mismatch"
        case .indexDirty: return "Index Dirty"
        case .applyFail: return "Apply Fail"
        default: return "Who knows?"
        }
    }
}

extension GitError.Code {
    
    public var detail: String {
        switch self {
        case .unknown: return "General error."
        case .notFound: return "Requested object could not be found."
        case .exists: return "Object exists preventing operation."
        case .ambiguous: return "More than one object matches."
        case .buffer: return "Output buffer too short to hold data."
        case .bareRepository: return "Operation not allowed on bare repository."
        case .unbornBranch: return "HEAD refers to branch with no commits."
        case .unmerged: return "Merge in progress prevented operation."
        case .nonFastForward: return "Reference was not fast-forwardable."
        case .invalidSpec: return "Name/ref spec was not in a valid format."
        case .conflict: return "Checkout conflicts prevented operation."
        case .locked: return "Lock file prevented operation."
        case .modified: return "Reference value does not match expected."
        case .auth: return "Authentication error."
        case .certificate: return "Server certificate is invalid."
        case .applied: return "Patch/merge has already been applied."
        case .peel: return "The requested peel operation is not possible."
        case .endOfFile: return "Unexpected end of file."
        case .invalid: return "Invalid operation or input."
        case .uncommitted: return "Uncommitted changes in index prevented operation."
        case .directory: return "The operation is not valid for a directory."
        case .mergeConflict: return "A merge conflict exists and cannot continue."
        case .passthrough: return "A user-configured callback refused to act."
        case .iteratorOver: return "Signals end of iteration with iterator."
        case .retry: return "Internal only."
        case .mismatch: return "Hashsum mismatch in object."
        case .indexDirty: return "Unsaved changes in the index would be overwritten."
        case .applyFail: return "Patch application failed."
        default: return "Who knows?"
        }
    }
}
