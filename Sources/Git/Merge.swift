
import Clibgit2
import Tagged

extension Repository {
    
    @GitActor
    public func merge(mergeOptions: Merge.Options) throws {
        try withUnsafePointer(to: mergeOptions.rawValue) { mergeOptions in
            try pointer.perform(git_merge, nil, 0, mergeOptions, nil)
        }
    }
}

public enum Merge {}

// MARK: - Merge.Options

extension Merge {

    /// Merging options.
    public struct Options {

        private let flags: Flags
        private let fileFavor: FileFavor
        private let fileFlags: FileFlags

        public init(
            flags: Flags,
            fileFavor: FileFavor,
            fileFlags: FileFlags
        ) {
            self.flags = flags
            self.fileFavor = fileFavor
            self.fileFlags = fileFlags
        }
    }
}

extension Merge.Options {

    fileprivate var rawValue: git_merge_options {
        var options = git_merge_options()
        options.flags = flags.rawValue
        options.file_favor = fileFavor.rawValue
        options.file_flags = fileFlags.rawValue
        return options
    }
}

// MARK: - Merge.Flags

extension Merge {

    /// Flags for ``Merge.Options``.
    ///
    /// A combination of these flags can be passed in via the `flags` value.
    public struct Flags: OptionSet, Sendable {
        
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        private init(_ status: git_merge_flag_t) {
            self.init(rawValue: status.rawValue)
        }
    }
}

extension Merge.Flags {

    /// Detect renames that occur between the common ancestor and the "ours"
    /// side or the common ancestor and the "theirs" side.  This will enable
    /// the ability to merge between a modified and renamed file.
    public static let findRenames = Self(GIT_MERGE_FIND_RENAMES)

    /// If a conflict occurs, exit immediately instead of attempting to
    /// continue resolving conflicts.  The merge operation will fail with
    /// GIT_EMERGECONFLICT and no index will be returned.
    public static let failOnConflict = Self(GIT_MERGE_FAIL_ON_CONFLICT)

    /// Do not write the REUC extension on the generated index
    public static let skipREUC = Self(GIT_MERGE_SKIP_REUC)

    /// If the commits being merged have multiple merge bases, do not build
    /// a recursive merge base (by merging the multiple merge bases),
    /// instead simply use the first base.  This flag provides a similar
    /// merge base to `git-merge-resolve`.
    public static let noRecursive = Self(GIT_MERGE_NO_RECURSIVE)

    /// Treat this merge as if it is to produce the virtual base
    /// of a recursive merge.  This will ensure that there are
    /// no conflicts, any conflicting regions will keep conflict
    /// markers in the merge result.
    public static let virtualBase = Self(GIT_MERGE_VIRTUAL_BASE)
}

// MARK: - Merge.FileFavor

extension Merge {
    
    /// Merge file favor options for ``Merge.Options`` instruct the file-level
    /// merging functionality how to deal with conflicting regions of the files.
    public struct FileFavor: Sendable {
        let rawValue: git_merge_file_favor_t
        private init(_ rawValue: git_merge_file_favor_t) {
            self.rawValue = rawValue
        }
    }
}

extension Merge.FileFavor {

    /// When a region of a file is changed in both branches, a conflict
    /// will be recorded in the index so that `git_checkout` can produce
    /// a merge file with conflict markers in the working directory.
    /// This is the default.
    public static let normal = Self(GIT_MERGE_FILE_FAVOR_NORMAL)

    /// When a region of a file is changed in both branches, the file
    /// created in the index will contain the "ours" side of any conflicting
    /// region.  The index will not record a conflict.
    public static let ours = Self(GIT_MERGE_FILE_FAVOR_OURS)

    /// When a region of a file is changed in both branches, the file
    /// created in the index will contain the "theirs" side of any conflicting
    /// region.  The index will not record a conflict.
    public static let theirs = Self(GIT_MERGE_FILE_FAVOR_THEIRS)

    /// When a region of a file is changed in both branches, the file
    /// created in the index will contain each unique line from each side,
    /// which has the result of combining both files.  The index will not
    /// record a conflict.
    public static let union = Self(GIT_MERGE_FILE_FAVOR_UNION)
}

// MARK: - Merge.FileFlag

extension Merge {

    /// File merging flags
    public struct FileFlags: OptionSet, Sendable {

        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        private init(_ status: git_merge_file_flag_t) {
            self.init(rawValue: status.rawValue)
        }
    }
}

extension Merge.FileFlags {

    /// Defaults
    public static let `default` = Self(GIT_MERGE_FILE_DEFAULT)

    /// Create standard conflicted merge files
    public static let merge = Self(GIT_MERGE_FILE_STYLE_MERGE)

    /// Create diff3-style files
    public static let diff3 = Self(GIT_MERGE_FILE_STYLE_DIFF3)

    /// Condense non-alphanumeric regions for simplified diff file
    public static let simplifyAlnum = Self(GIT_MERGE_FILE_SIMPLIFY_ALNUM)

    /// Ignore all whitespace
    public static let ignoreWhitespace = Self(GIT_MERGE_FILE_IGNORE_WHITESPACE)

    /// Ignore changes in amount of whitespace
    public static let ignoreWhitespaceChange = Self(GIT_MERGE_FILE_IGNORE_WHITESPACE_CHANGE)

    /// Ignore whitespace at end of line
    public static let ignoreWhitespaceEOL = Self(GIT_MERGE_FILE_IGNORE_WHITESPACE_EOL)

    /// Use the "patience diff" algorithm
    public static let patienceDiff = Self(GIT_MERGE_FILE_DIFF_PATIENCE)

    /// Use the "patience diff" algorithm
    public static let minimalDiff = Self(GIT_MERGE_FILE_DIFF_MINIMAL)

    /// Create zdiff3 ("zealous diff3")-style files
    public static let zdiff3 = Self(GIT_MERGE_FILE_STYLE_ZDIFF3)

    /// Do not produce file conflicts when common regions have
    /// changed; keep the conflict markers in the file and accept
    /// that as the merge result.
    public static let acceptConflicts = Self(GIT_MERGE_FILE_ACCEPT_CONFLICTS)
}

// MARK: - Merge.MarkerSize

extension Merge {

    /// The size of conflict markers (eg, "<<<<<<<").
    public struct MarkerSize {
        fileprivate let value: Int32
    }
}

extension Merge.MarkerSize {

    public static let `default` = Self(value: GIT_MERGE_CONFLICT_MARKER_SIZE)
}

extension Merge.MarkerSize: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int32) {
        self.init(value: value)
    }
}
