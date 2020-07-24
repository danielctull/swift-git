
import Clibgit2
import Foundation

public struct Signature: Equatable, Hashable {
    public let name: String
    public let email: String
    public let date: Date
    public let timeZone: TimeZone
}

extension Signature {

    init(_ signature: git_signature) throws {
        name = try String(signature.name)
        email = try String(signature.email)
        date = Date(timeIntervalSince1970: TimeInterval(signature.when.time))
        timeZone = TimeZone(secondsFromGMT: 60 * Int(signature.when.offset))!
    }
}
