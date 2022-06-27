
struct GitTask<Output> {
    private let function: () throws -> Output
    func callAsFunction() throws -> Output { try function() }
}

extension GitTask where Output == Void {

    init(task: @escaping () -> Int32) {
        self.init {
            let result = task()
            if let error = LibGit2Error(result) { throw error }
        }
    }
}

extension GitTask {

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
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, self.pointer) }
    }

    func task<A>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, self.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, self.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, self.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, self.pointer, a, b, c, d) }
    }
}

// MARK: - Creating a task from a GitReference

extension GitReference {

    func task(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, pointer.pointer) }
    }

    func task<A>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, pointer.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, pointer.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, pointer.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<OpaquePointer> {
        GitTask { task($0, pointer.pointer, a, b, c, d) }
    }
}

extension GitReference {

    func task(
        for task: @escaping (OpaquePointer) -> Int32
    ) -> GitTask<Void> {
        GitTask { task(pointer.pointer) }
    }

    func task<A>(
        for task: @escaping (OpaquePointer, A) -> Int32,
        _ a: A
    ) -> GitTask<Void> {
        GitTask { task(pointer.pointer, a) }
    }

    func task<A, B>(
        for task: @escaping (OpaquePointer, A, B) -> Int32,
        _ a: A,
        _ b: B
    ) -> GitTask<Void> {
        GitTask { task(pointer.pointer, a, b) }
    }

    func task<A, B, C>(
        for task: @escaping (OpaquePointer, A, B, C) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C
    ) -> GitTask<Void> {
        GitTask { task(pointer.pointer, a, b, c) }
    }

    func task<A, B, C, D>(
        for task: @escaping (OpaquePointer, A, B, C, D) -> Int32,
        _ a: A,
        _ b: B,
        _ c: C,
        _ d: D
    ) -> GitTask<Void> {
        GitTask { task(pointer.pointer, a, b, c, d) }
    }
}
