
protocol GitReference {
    init(pointer: GitPointer) throws
    var pointer: GitPointer { get }
}

extension GitReference {

    init(
        create: GitPointer.Create,
        configure: GitPointer.Configure? = nil,
        free: @escaping GitPointer.Free
    ) throws {
        try self.init(
            pointer: GitPointer(
                create: create,
                configure: configure,
                free: free)
        )
    }
}
