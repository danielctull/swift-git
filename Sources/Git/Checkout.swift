import libgit2

extension Repository {

  public func checkoutHead(options: Checkout.Options = .init()) throws {
    try withUnsafePointer(to: options.rawValue) { options in
      try pointer.perform(git_checkout_head, nil)
    }
  }
}

public enum Checkout {}

// MARK: - Checkout.Options

extension Checkout {

  public struct Options {

    public init() {
    }
  }
}

extension Checkout.Options {

  var rawValue: git_checkout_options {
    let options = git_checkout_options()
    return options
  }
}

// MARK: - Checkout.Strategy

extension Checkout {

  /// Checkout behavior flags
  ///
  /// In libgit2, checkout is used to update the working directory and index
  /// to match a target tree.  Unlike git checkout, it does not move the HEAD
  /// commit for you - use `git_repository_set_head` or the like to do that.
  ///
  /// Checkout looks at (up to) four things: the "target" tree you want to
  /// check out, the "baseline" tree of what was checked out previously, the
  /// working directory for actual files, and the index for staged changes.
  ///
  /// You give checkout one of three strategies for update:
  ///
  /// - ``none`` is a dry-run strategy that checks for conflicts,
  ///   etc., but doesn't make any actual changes.
  ///
  /// - ``force`` is at the opposite extreme, taking any action to
  ///   make the working directory match the target (including potentially
  ///   discarding modified files).
  ///
  /// - ``safe`` is between these two options, it will only make
  ///   modifications that will not lose changes.
  ///
  ///   |                                    | target == baseline               | target != baseline                    |
  ///   |------------------------------------|----------------------------------|---------------------------------------|
  ///   | workdir == baseline                | no action                        | create, update, or delete file        |
  ///   | workdir exists and is != baseline  | no action, notify dirty MODIFIED | conflict (notify and cancel checkout) |
  ///   |  workdir missing, baseline present | notify dirty DELETED             | create file                           |
  ///
  /// To emulate `git checkout`, use ``safe`` with a checkout
  /// notification callback (see below) that displays information about dirty
  /// files.  The default behavior will cancel checkout on conflicts.
  ///
  /// To emulate `git checkout-index`, use ``safe`` with a
  /// notification callback that cancels the operation if a dirty-but-existing
  /// file is found in the working directory.  This core git command isn't
  /// quite "force" but is sensitive about some types of changes.
  ///
  /// To emulate `git checkout -f`, use ``force``.
  ///
  ///
  /// There are some additional flags to modify the behavior of checkout:
  ///
  /// - ``allowConflicts`` makes ``safe`` mode apply safe file updates
  ///   even if there are conflicts (instead of cancelling the checkout).
  ///
  /// - ``removeUntracked`` means remove untracked files (i.e. not
  ///   in target, baseline, or index, and not ignored) from the working dir.
  ///
  /// - ``removeIgnored`` means remove ignored files (that are also
  ///   untracked) from the working directory as well.
  ///
  /// - ``updateOnly`` means to only update the content of files that
  ///   already exist.  Files will not be created nor deleted.  This just skips
  ///   applying adds, deletes, and typechanges.
  ///
  /// - ``dontUpdateIndex`` prevents checkout from writing the
  ///   updated files' information to the index.
  ///
  /// - Normally, checkout will reload the index and git attributes from disk
  ///   before any operations. ``noRefresh`` prevents this reload.
  ///
  /// - Unmerged index entries are conflicts. ``skipUnmerged`` skips
  ///   files with unmerged index entries instead.  ``useOurs`` and
  ///   ``useTheirs`` to proceed with the checkout using either the
  ///   stage 2 ("ours") or stage 3 ("theirs") version of files in the index.
  ///
  /// - ``dontOverwriteIgnored`` prevents ignored files from being
  ///   overwritten.  Normally, files that are ignored in the working directory
  ///   are not considered "precious" and may be overwritten if the checkout
  ///   target contains that file.
  ///
  /// - ``dontRemoveExisting`` prevents checkout from removing
  ///   files or folders that fold to the same name on case insensitive
  ///   filesystems.  This can cause files to retain their existing names
  ///   and write through existing symbolic links.
  public struct Strategy: OptionSet, Equatable, Hashable, Sendable {
    public let rawValue: Option
    public init(rawValue: Option) {
      self.rawValue = rawValue
    }
  }
}

extension Checkout.Strategy: GitOptionSet {

  typealias OptionType = git_checkout_strategy_t

  /// default is a dry run, no actual updates.
  public static let none = Self(GIT_CHECKOUT_NONE)

  /// Allow safe updates that cannot overwrite uncommitted data.
  /// If the uncommitted changes don't conflict with the checked out files,
  /// the checkout will still proceed, leaving the changes intact.
  ///
  /// Mutually exclusive with ``force``; ``force`` takes precedence over
  /// ``safe``.
  public static let safe = Self(GIT_CHECKOUT_SAFE)

  /// Allow all updates to force working directory to look like index.
  ///
  /// Mutually exclusive with GIT_CHECKOUT_SAFE.
  /// GIT_CHECKOUT_FORCE takes precedence over GIT_CHECKOUT_SAFE.
  public static let force = Self(GIT_CHECKOUT_FORCE)

  /// Allow checkout to recreate missing files
  public static let recreateMissing = Self(GIT_CHECKOUT_RECREATE_MISSING)

  /// Allow checkout to make safe updates even if conflicts are found
  public static let allowConflicts = Self(GIT_CHECKOUT_ALLOW_CONFLICTS)

  /// Remove untracked files not in index (that are not ignored)
  public static let removeUntracked = Self(GIT_CHECKOUT_REMOVE_UNTRACKED)

  /// Remove ignored files not in index
  public static let removeIgnored = Self(GIT_CHECKOUT_REMOVE_IGNORED)

  /// Only update existing files, don't create new ones
  public static let updateOnly = Self(GIT_CHECKOUT_UPDATE_ONLY)

  /// Normally checkout updates index entries as it goes; this stops that.
  ///
  /// Implies ``dontWriteIndex``.
  public static let dontUpdateIndex = Self(GIT_CHECKOUT_DONT_UPDATE_INDEX)

  /// Don't refresh index/config/etc before doing checkout
  public static let noRefresh = Self(GIT_CHECKOUT_NO_REFRESH)

  /// Allow checkout to skip unmerged files
  public static let skipUnmerged = Self(GIT_CHECKOUT_SKIP_UNMERGED)

  /// For unmerged files, checkout stage 2 from index
  public static let useOurs = Self(GIT_CHECKOUT_USE_OURS)

  /// For unmerged files, checkout stage 3 from index
  public static let useTheirs = Self(GIT_CHECKOUT_USE_THEIRS)

  /// Treat pathspec as simple list of exact match file paths
  public static let disablePathspecMatch = Self(
    GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH
  )

  /// Ignore directories in use, they will be left empty
  public static let skipLockedDirectories = Self(
    GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES
  )

  /// Don't overwrite ignored files that exist in the checkout target
  public static let dontOverwriteIgnored = Self(
    GIT_CHECKOUT_DONT_OVERWRITE_IGNORED
  )

  /// Write normal merge files for conflicts
  public static let conflictStyleMerge = Self(GIT_CHECKOUT_CONFLICT_STYLE_MERGE)

  /// Include common ancestor data in diff3 format files for conflicts
  public static let conflictStyleDiff3 = Self(GIT_CHECKOUT_CONFLICT_STYLE_DIFF3)

  /// Don't overwrite existing files or folders
  public static let dontRemoveExisting = Self(GIT_CHECKOUT_DONT_REMOVE_EXISTING)

  /// Normally checkout writes the index upon completion; this prevents that.
  public static let dontWriteIndex = Self(GIT_CHECKOUT_DONT_WRITE_INDEX)

  /// Show what would be done by a checkout.
  ///
  /// Stop after sending notifications; don't update the working directory
  /// or index.
  public static let dryRun = Self(GIT_CHECKOUT_DRY_RUN)

  /// Include common ancestor data in zdiff3 format for conflicts
  public static let conflictStyleZdiff3 = Self(
    GIT_CHECKOUT_CONFLICT_STYLE_ZDIFF3
  )

  // THE FOLLOWING OPTIONS ARE NOT YET IMPLEMENTED

  /// Recursively checkout submodules with same options (NOT IMPLEMENTED)
  //public static let updateSubmodules = Self(GIT_CHECKOUT_UPDATE_SUBMODULES)

  /// Recursively checkout submodules if HEAD moved in super repo (NOT IMPLEMENTED)
  //public static let updateSubmodulesIfChanged = Self(GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED)
}
