
func Unwrap<Value>(_ optional: Value?) throws -> Value {
    guard let value = optional else { throw GitError(code: .notFound) }
    return value
}
