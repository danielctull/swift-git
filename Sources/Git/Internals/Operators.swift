
precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication
func |> <A, B>(x: A, f: (A) throws -> B) rethrows -> B { try f(x) }

precedencegroup OptionalForwardApplication {
    associativity: left
    higherThan: ForwardApplication
}

infix operator ?>: OptionalForwardApplication
func ?> <A, B>(x: A?, f: (A) throws -> B) rethrows -> B? { try x.map(f) }

precedencegroup ForceUnwrapForwardApplication {
    associativity: left
    higherThan: ForwardApplication
}

infix operator !>: ForceUnwrapForwardApplication
func !> <A, B>(x: A?, f: (A) throws -> B) rethrows -> B { try f(x!) }
