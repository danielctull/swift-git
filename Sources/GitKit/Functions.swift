
import Clibgit2

extension OpaquePointer {

    init(_ gitFunction: (UnsafeMutablePointer<OpaquePointer?>) -> Int32) throws {
        git_libgit2_init()
        var pointer: OpaquePointer?
        let result = withUnsafeMutablePointer(to: &pointer, gitFunction)
        if let error = GitError(result) { throw error }
        guard let unwrapped = pointer else { throw GitError(.unknown) }
        self = unwrapped
    }
}
