
import Clibgit2
import Tagged

extension Repository {
    
    @GitActor
    public func rebase(branch: Branch) throws -> Rebase {
            try Rebase(
                create: pointer.create(git_rebase_init),
                free: git_rebase_free)
        }
    }
}

public struct Rebase {

}

// MARK: - Rebase.Options

extension Rebase {
    
    public struct Options: OptionSet, Sendable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

extension Rebase.Options {

    private init(_ options: git_rebase_options) {
        self.init(rawValue: options.rawValue)
    }

    public init() { self.init(git_rebase_options(version: <#T##UInt32#>, quiet: <#T##Int32#>, inmemory: <#T##Int32#>, rewrite_notes_ref: <#T##UnsafePointer<CChar>!#>, merge_options: <#T##git_merge_options#>, checkout_options: <#T##git_checkout_options#>, commit_create_cb: <#T##git_commit_create_cb!##git_commit_create_cb!##(UnsafeMutablePointer<git_oid>?, UnsafePointer<git_signature>?, UnsafePointer<git_signature>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?, OpaquePointer?, Int, UnsafeMutablePointer<OpaquePointer?>?, UnsafeMutableRawPointer?) -> Int32#>, signing_cb: <#T##((UnsafeMutablePointer<git_buf>?, UnsafeMutablePointer<git_buf>?, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Int32)!##((UnsafeMutablePointer<git_buf>?, UnsafeMutablePointer<git_buf>?, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Int32)!##(UnsafeMutablePointer<git_buf>?, UnsafeMutablePointer<git_buf>?, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Int32#>, payload: <#T##UnsafeMutableRawPointer!#>)) }
    public static let time = Self(GIT_SORT_TIME)
    public static let topological = Self(GIT_SORT_TOPOLOGICAL)
    public static let reverse = Self(GIT_SORT_REVERSE)
}

// MARK: - SortOptions

public struct SortOptions: OptionSet, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension SortOptions {

    private init(_ sort: git_sort_t) {
        self.init(rawValue: sort.rawValue)
    }

    public init() { self.init(GIT_SORT_NONE) }
    public static let time = Self(GIT_SORT_TIME)
    public static let topological = Self(GIT_SORT_TOPOLOGICAL)
    public static let reverse = Self(GIT_SORT_REVERSE)
}

// MARK: - GitPointerInitialization

extension Commit: GitPointerInitialization {}
