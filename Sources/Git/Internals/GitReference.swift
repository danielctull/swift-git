
protocol GitReference: Sendable {

    @GitActor
    init(pointer: GitPointer) throws
    var pointer: GitPointer { get }
}

extension GitReference {

    @GitActor
    init(
        create: @escaping GitPointer.Create,
        free: @escaping GitPointer.Free
    ) throws {
        try self.init(
            pointer: GitPointer(
                create: create,
                free: free)
        )
    }
}
