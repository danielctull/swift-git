
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

extension UInt32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}
