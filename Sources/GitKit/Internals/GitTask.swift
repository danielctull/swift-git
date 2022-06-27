
struct GitTask<Input, Output> {
    private let function: (Input) throws -> Output
    func callAsFunction(_ input: Input) throws -> Output { try function(input) }
}

extension GitTask where Input == Void {
    func callAsFunction() throws -> Output { try function(()) }
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

    func task(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, self.pointer) }
    }

    func task<A>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, self.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, self.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, self.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, self.pointer, a, b, c, d) }
    }
}

// MARK: - Creating a task from a GitReference

extension GitReference {

    func task(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, pointer.pointer) }
    }

    func task<A>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, pointer.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, pointer.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void, OpaquePointer> {
        GitTask { task($0, pointer.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void, OpaquePointer> {
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
