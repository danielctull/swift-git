
import Clibgit2
import Foundation

public struct Signature {
    public let name: String
    public let email: String
    public let date: Date
    public let timeZone: TimeZone

    init(_ signature: git_signature) {
        name = String(validatingUTF8: signature.name)!
        email = String(validatingUTF8: signature.email)!
        date = Date(timeIntervalSince1970: TimeInterval(signature.when.time))
        timeZone = TimeZone(secondsFromGMT: 60 * Int(signature.when.offset))!
    }
}
