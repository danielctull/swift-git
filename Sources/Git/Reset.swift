
import Clibgit2

extension Repository {

    /// Sets the current head to the specified commit oid and optionally
    /// resets the index and working tree to match.
    ///
    /// * ``soft``: the Head will be moved to the commit.
    ///
    /// * ``mixed``: trigger a soft reset, plus the index will be replaced
    /// with the content of the commit tree.
    ///
    /// * ``hard``: trigger a mixed reset and the working directory will be
    /// replaced with the content of the index. (Untracked and ignored files
    /// will be left alone, however.)
    ///
    /// - Parameters:
    ///   - commitish: Committish to which the Head should be moved to. This
    ///                object must belong to the given `repo` and can either be
    ///                a ``Commit`` or a ``Tag``. When a tag is being passed,
    ///                it should be dereferenceable to a commit which oid will
    ///                be used as the target of the branch.
    ///   - operation: Kind of reset operation to perform.
    @GitActor
    public func reset(
        to commitish: Commitish,
        operation: Reset.Operation
    ) throws {
        try pointer.perform(
            git_reset,
            commitish.pointer.pointer,
            git_reset_t(rawValue: operation.rawValue),
            nil
        )
    }
}

public enum Reset {}

// MARK: - Reset.Operation

extension Reset {

    /// Kinds of reset operation
    public struct Operation: Equatable, Hashable, Sendable {
        fileprivate let rawValue: UInt32
    }
}

extension Reset.Operation {

    /// Move the head to the given commit.
    public static let soft = Self(rawValue: GIT_RESET_SOFT.rawValue)

    /// ``soft`` plus reset index to the commit.
    public static let mixed = Self(rawValue: GIT_RESET_MIXED.rawValue)

    /// ``mixed`` plus changes in working tree discarded.
    public static let hard = Self(rawValue: GIT_RESET_HARD.rawValue)
}
