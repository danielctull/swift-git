
import Cgit2

extension UInt32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}
