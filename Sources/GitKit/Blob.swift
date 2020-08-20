
import Clibgit2
import Foundation
import Tagged

public struct Blob: Identifiable {
    let blob: GitPointer
    public typealias ID = Tagged<Blob, Object.ID>
    public let id: ID
    public let data: Data
    public let isBinary: Bool
}

// MARK: - Git Initialiser

extension Blob {

    init(_ blob: GitPointer) throws {
        self.blob = blob
        id = try ID(object: blob)
        let size = Int(blob.get(git_blob_rawsize))
        let content = try Unwrap(blob.get(git_blob_rawcontent))
        data = Data(bytes: content, count: size)
        isBinary = blob.check(git_blob_is_binary)
    }
}
