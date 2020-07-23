
import Clibgit2
import Tagged

public struct Note: Identifiable {
    public typealias ID = Tagged<Note, String>
    public let id: ID
}

extension Note {

    init(_ note: GitPointer) throws {
        guard note.check(git_reference_is_note) else { throw GitError(.unknown) }
        id = ID(rawValue: String(validatingUTF8: note.get(git_reference_name))!)
    }
}
