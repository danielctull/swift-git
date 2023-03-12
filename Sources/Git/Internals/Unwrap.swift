
func Unwrap<Value>(_ optional: Value?) throws -> Value {
    guard let value = optional else { throw GitError(.notFound) }
    return value
}
