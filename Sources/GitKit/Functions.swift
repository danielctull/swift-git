
import Clibgit2

extension UnsafePointer {

    init(_ gitFunction: (UnsafeMutablePointer<Self?>) -> Int32) throws {
        git_libgit2_init()
        var pointer: Self?
        let result = withUnsafeMutablePointer(to: &pointer, gitFunction)
        if let error = GitError(result) { throw error }
        guard let unwrapped = pointer else { throw GitError(.unknown) }
        self = unwrapped
    }
}

extension Int32 {
    static var `true`: Int32 { 1 }
    static var `false`: Int32 { 0 }
}
