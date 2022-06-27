
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
            if let error = LibGit2Error(result) { throw error }
        }
    }
}

extension GitTask where Input == Void, Output == Void {

    init(task: @escaping () -> Int32) {
        self.init {
            let result = task()
            if let error = LibGit2Error(result) { throw error }
        }
    }
}

extension GitTask where Input == Void {

    init(task: @escaping (UnsafeMutablePointer<Output?>) -> Int32) {
        self.init {
            var output: Output?
            let result = withUnsafeMutablePointer(to: &output, task)
            if let error = LibGit2Error(result) { throw error }
            return try Unwrap(output)
        }
    }
}

// MARK: - Creating a task from a GitPointer

extension GitPointer {

    func task<Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer) }
    }

    func task<A, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a) }
    }

    func task<A, B, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a, b) }
    }

    func task<A, B, C, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task($0, self.pointer, a, b, c) }
    }

    func task<A, B, C, D, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C, D) -> Int32,
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
        for task: @escaping (OpaquePointer) -> Int32
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer) }
    }

    func task<A>(
        for task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Void> {
        GitTask { task(self.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
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
        for task: @escaping (OpaquePointer) -> Output
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer) }
    }

    func task<A, Output>(
        for task: @escaping (OpaquePointer, A) -> Output,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a) }
    }

    func task<A, B, Output>(
        for task: @escaping (OpaquePointer, A, B) -> Output,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a, b) }
    }

    func task<A, B, C, Output>(
        for task: @escaping (OpaquePointer, A, B, C) -> Output,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task(self.pointer, a, b, c) }
    }

    func task<A, B, C, D, Output>(
        for task: @escaping (OpaquePointer, A, B, C, D) -> Output,
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
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer) }
    }

    func task<A, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a) }
    }

    func task<A, B, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b) }
    }

    func task<A, B, C, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b, c) }
    }

    func task<A, B, C, D, Output>(
        for task: @escaping (UnsafeMutablePointer<Output?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Output> {
        GitTask { task($0, pointer.pointer, a, b, c, d) }
    }
}

extension GitReference {

    func task(
        for task: @escaping (OpaquePointer) -> Int32
    ) -> GitTask<Void, Void> {
        GitTask { task(pointer.pointer) }
    }

    func task<A>(
        for task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, Void> {
        GitTask { task(pointer.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, Void> {
        GitTask { task(pointer.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, Void> {
        GitTask { task(pointer.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, Void> {
        GitTask { task(pointer.pointer, a, b, c, d) }
    }
}
