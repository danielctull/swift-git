
import Clibgit2

final class GitPointer {

    let pointer: OpaquePointer
    private let free: (OpaquePointer) -> ()

    deinit { free(pointer) }

    init(
        create: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        free: @escaping (OpaquePointer) -> Void
    ) throws {
        git_libgit2_init()
        var pointer: OpaquePointer?
        let result = withUnsafeMutablePointer(to: &pointer, create)
        if let error = GitError(result) { free(pointer!); throw error }
        self.pointer = pointer!
        self.free = free
    }
}
