// This is for the iterator tasks.
func firstOutput<A, B, C, Value>(
  of task: @escaping (A, UnsafeMutablePointer<B>, C) -> Value
) -> (A, C) -> Value {
  { a, c in
    let b = UnsafeMutablePointer<B>.allocate(capacity: 1)
    defer { b.deallocate() }
    return task(a, b, c)
  }
}
