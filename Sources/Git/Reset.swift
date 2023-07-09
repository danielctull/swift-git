
import Clibgit2
import Tagged

extension Repository {

    @GitActor
    public func reset(
        commit: Commit,
        operation: Reset.Operation,
        checkoutOptions: Checkout.Options = .init()
    ) throws {
        try withUnsafePointer(to: checkoutOptions.rawValue) { checkoutOptions in
            try pointer.perform(
                git_reset,
                commit.pointer.pointer,
                git_reset_t(rawValue: operation.rawValue),
                checkoutOptions
            )
        }
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
