
import Clibgit2
import Foundation
import Tagged

// MARK: - Blob

public struct Blob: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Blob, Object.ID>
    public let id: ID
    public let data: Data
    public let isBinary: Bool

    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)
        let size = Int(pointer.get(git_blob_rawsize))
        let content = try Unwrap(pointer.get(git_blob_rawcontent))
        data = Data(bytes: content, count: size)
        isBinary = pointer.check(git_blob_is_binary)
    }
}
