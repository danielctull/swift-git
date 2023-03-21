
import Clibgit2

extension UInt32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}

extension Int32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}

extension Bool {

    init(_ value: Int32) {
        self = value == 1
    }
}
