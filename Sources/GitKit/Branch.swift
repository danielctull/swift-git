
import Clibgit2

public struct Branch {
    let pointer: OpaquePointer
    public let name: String
}

extension Branch {

    init(_ pointer: OpaquePointer) throws {
        guard git_reference_is_branch(pointer) != 0 else { throw GitError(.unknown) }
        let name = try UnsafePointer<Int8> { git_branch_name($0, pointer) }
        self.name = String(validatingUTF8: name)!
        self.pointer = pointer
    }
}
