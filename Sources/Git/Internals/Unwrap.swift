
func Unwrap<Value>(_ optional: Value?) throws -> Value {
    guard let value = optional else { throw GitError(code: .notFound) }
    return value
}

func preconditionUnwrap<Value>(
    _ value: Value?,
    _ message: String,
    file: StaticString = #file,
    line: UInt = #line
) -> Value {
    precondition(value != nil, message, file: file, line: line)
    return value!
}
