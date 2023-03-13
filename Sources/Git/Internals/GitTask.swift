
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

    func task<Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer) }
    }

    func task<A, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a) }
    }

    func task<A, B, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a, b) }
    }

    func task<A, B, C, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a, b, c) }
    }

    func task<A, B, C, D, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a, b, c, d) }
    }
}

extension GitPointer {

    func task(
        _ task: @escaping (OpaquePointer) -> Int32
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer) }
    }

    func task<A>(
        _ task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a) }
    }

    func task<A, B>(
        _ task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a, b) }
    }

    func task<A, B, C>(
        _ task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        _ task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a, b, c, d) }
    }
}

extension GitPointer {

    func task<Output>(
        _ task: @escaping (OpaquePointer) -> Output
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer) }
    }

    func task<A, Output>(
        _ task: @escaping (OpaquePointer, A) -> Output,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a) }
    }

    func task<A, B, Output>(
        _ task: @escaping (OpaquePointer, A, B) -> Output,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a, b) }
    }

    func task<A, B, C, Output>(
        _ task: @escaping (OpaquePointer, A, B, C) -> Output,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a, b, c) }
    }

    func task<A, B, C, D, Output>(
        _ task: @escaping (OpaquePointer, A, B, C, D) -> Output,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a, b, c, d) }
    }
}

// MARK: - Creating a task from a GitReference

extension GitReference {

    func task<Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer) }
    }

    @_disfavoredOverload
    func task<A, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a) }
    }

    @_disfavoredOverload
    func task<A, B, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b) }
    }

    @_disfavoredOverload
    func task<A, B, C, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b, c) }
    }

    @_disfavoredOverload
    func task<A, B, C, D, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b, c, d) }
    }
}

// String variants, which will correctly convert String to UnsafePointer<CChar>,
// unlike the generic functions above.
extension GitReference {

    func task<Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, UnsafePointer<CChar>) -> Int32,
        _ a: String
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a) }
    }

    func task<B, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, UnsafePointer<CChar>, B) -> Int32,
        _ a: String,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b) }
    }


    func task<B, C, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, UnsafePointer<CChar>, B, C) -> Int32,
        _ a: String,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b, c) }
    }
}

extension GitReference {

    func task<A, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, UnsafePointer<A>) -> Int32,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask {
            var a = a
            return task($0, pointer.pointer, &a)
        }
    }

    func task<A, B, Output>(
        _ task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, UnsafePointer<A>, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask {
            var a = a
            return task($0, pointer.pointer, &a, b)
        }
    }
}
