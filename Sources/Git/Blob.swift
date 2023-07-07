
import Clibgit2
import Foundation
import Tagged

// MARK: - Blob

public struct Blob: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public typealias ID = Tagged<Blob, Object.ID>
    public let id: ID
    public let data: Data
    public let isBinary: Bool

    @GitActor
    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)

        let size = pointer.get(git_blob_rawsize) |> Int.init
        let content = try pointer.get(git_blob_rawcontent) |> Unwrap
        data = Data(bytes: content, count: size)

        isBinary = pointer.get(git_blob_is_binary) |> Bool.init
    }
}

// MARK: - GitPointerInitialization

extension Blob: GitPointerInitialization {}
