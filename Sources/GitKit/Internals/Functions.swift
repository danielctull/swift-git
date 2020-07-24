
import Clibgit2

extension UInt32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}

extension String {

    init(_ characters: UnsafePointer<CChar>) throws {
        guard let string = Self(validatingUTF8: characters) else {
            throw GitKitError.unexpectedNilValue
        }
        self = string
    }
}
