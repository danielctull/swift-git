
protocol GitReference {
    init(pointer: GitPointer) throws
    var pointer: GitPointer { get }
}

extension GitReference {

    init(
        create: @autoclosure () throws -> OpaquePointer,
        free: @escaping GitPointer.Free
    ) throws {
        try self.init(
            pointer: GitPointer(
                create: create(),
                free: free)
        )
    }
}
