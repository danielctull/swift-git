
precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication
func |> <A, B>(x: A, f: (A) throws -> B) rethrows -> B { try f(x) }
