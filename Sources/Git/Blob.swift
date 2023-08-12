
import Clibgit2
import Foundation

// MARK: - Blob

public struct Blob: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let data: Data
    public let isBinary: Bool

    @GitActor
    init(pointer: GitPointer) {
        self.pointer = pointer
        id = ID(objectID: Object.ID(object: pointer))
        
        let size = pointer.get(git_blob_rawsize) |> Int.init
        let content = pointer.get(git_blob_rawcontent)
        data = Data(bytes: content!, count: size)

        isBinary = pointer.get(git_blob_is_binary) |> Bool.init
    }
}

// MARK: - Blob.ID

extension Blob {

    public struct ID: Equatable, Hashable, Sendable {
        public let objectID: Object.ID
    }
}

extension Blob.ID: CustomStringConvertible {
    public var description: String { objectID.description }
}

// MARK: - GitPointerInitialization

extension Blob: GitPointerInitialization {}
