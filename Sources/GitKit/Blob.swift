
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

    init(_ blob: GitPointer) async throws {
        self.blob = blob
        id = try await ID(object: blob)
        let size = await Int(blob.get(git_blob_rawsize))
        let content = try await Unwrap(blob.get(git_blob_rawcontent))
        data = Data(bytes: content, count: size)
        isBinary = await blob.check(git_blob_is_binary)
    }
}
