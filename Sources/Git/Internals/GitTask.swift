
struct GitTask<Input, Output> {
    let function: (Input) throws -> Output
    func callAsFunction(_ input: Input) throws -> Output { try function(input) }
}

extension GitTask where Input == Void {
    func callAsFunction() throws -> Output { try function(()) }
}

extension GitTask where Output == Void {

    init(task: @escaping (Input) -> Int32) {
        self.init { input in
            let result = task(input)
            try GitError.check(result)
        }
    }
}

extension GitTask where Input == Void, Output == Void {

    init(task: @escaping () -> Int32) {
        self.init {
            let result = task()
            try GitError.check(result)
        }
    }
}

extension GitTask where Input == Void {

    init(task: @escaping (UnsafeMutablePointer<Output?>) -> Int32) {
        self.init {
            var output: Output?
            let result = withUnsafeMutablePointer(to: &output, task)
            try GitError.check(result)
            return try Unwrap(output)
        }
    }
}

// MARK: - Converting a task

extension GitTask {

    func map<NewOutput>(
        _ transform: @escaping (Output) throws -> NewOutput
    ) -> GitTask<Input, NewOutput> {
        .init { input in
            let output = try function(input)
            return try transform(output)
        }
    }
}

// MARK: - Creating a task from a GitPointer

extension GitPointer {

    func task<Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer) -> Int32
    ) -> () throws -> Value {
        {
            var value: Value?
            let result = withUnsafeMutablePointer(to: &value) { task($0, self.pointer) }
            try GitError.check(result)
            return try Unwrap(value)
        }
    }

    func task<A, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> () throws -> Value {
        {
            var value: Value?
            let result = withUnsafeMutablePointer(to: &value) { task($0, self.pointer, a) }
            try GitError.check(result)
            return try Unwrap(value)
        }
    }

    func task<A, B, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> () throws -> Value {
        {
            var value: Value?
            let result = withUnsafeMutablePointer(to: &value) { task($0, self.pointer, a, b) }
            try GitError.check(result)
            return try Unwrap(value)
        }
//        self.task { output, pointer in task(output, pointer, a, b) }
    }

    func task<A, B, C, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> () throws -> Value {
        self.task { output, pointer in task(output, pointer, a, b, c) }
    }

    func task<A, B, C, D, Value>(
        _ task: @escaping (UnsafeMutablePointer<Value?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> () throws -> Value {
        self.task { output, pointer in task(output, pointer, a, b, c, d) }
    }
}

extension GitPointer {

    func task(
        _ task: @escaping (OpaquePointer) -> Int32
    ) -> () throws -> Void {
        { try self.perform(task) }
    }

    func task<A>(
        _ task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) -> () throws -> Void {
        { try self.perform(task, a) }
    }

    func task<A, B>(
        _ task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> () throws -> Void {
        { try self.perform(task, a, b) }
    }

    func task<A, B, C>(
        _ task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> () throws -> Void {
        { try self.perform(task, a, b, c) }
    }

    func task<A, B, C, D>(
        _ task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> () throws -> Void {
        { try self.perform(task, a, b, c, d) }
    }
}

extension GitPointer {

    func task<Value>(
        _ task: @escaping (OpaquePointer) -> Value
    ) -> () -> Value {
        { self.get(task) }
    }

    func task<A, Value>(
        _ task: @escaping (OpaquePointer, A) -> Value,
        _ a: A
    ) -> () -> Value {
        { self.get(task, a) }
    }

    func task<A, B, Value>(
        _ task: @escaping (OpaquePointer, A, B) -> Value,
        _ a: A,
        _ b: B
    ) -> () -> Value {
        { self.get(task, a, b) }
    }

    func task<A, B, C, Value>(
        _ task: @escaping (OpaquePointer, A, B, C) -> Value,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> () -> Value {
        { self.get(task, a, b, c) }
    }

    func task<A, B, C, D, Value>(
        _ task: @escaping (OpaquePointer, A, B, C, D) -> Value,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> () -> Value {
        { self.get(task, a, b, c, d) }
    }
}
