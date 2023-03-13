
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

        let size = pointer.get(git_blob_rawsize, as: Int.init)

        let content = try pointer
            .task(git_blob_rawcontent)
            .map(Unwrap)()

        data = Data(bytes: content, count: size)

        isBinary = pointer.check(git_blob_is_binary)
    }
}
