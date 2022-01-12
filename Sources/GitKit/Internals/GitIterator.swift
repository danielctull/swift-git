//
//struct GitIterator<Element> {
//
//    let iterator: GitPointer
//    let nextElement: (GitPointer) async throws -> Element?
//
//    init(
//        createIterator: GitPointer.Create,
//        configureIterator: (GitPointer.Configure)? = nil,
//        freeIterator: @escaping GitPointer.Free,
//        nextElement: @escaping (GitPointer) async throws -> Element?
//    ) throws {
//        iterator = try GitPointer(create: createIterator, configure: configureIterator, free: freeIterator)
//        self.nextElement = nextElement
//    }
//}
//
//extension GitIterator: AsyncSequence {
//    
//    struct Iter: AsyncIteratorProtocol {
//        let iterator: GitPointer
//        let nextElement: (GitPointer) async throws -> Element?
//
//        mutating func next() async throws -> Element? {
//            do {
//                return try await nextElement(iterator)
//            } catch let error as LibGit2Error where error.code == .iteratorOver {
//                return nil
//            } catch {
//                throw error
//            }
//        }
//    }
//
//    func makeAsyncIterator() -> Iter {
//        Iter(iterator: iterator, nextElement: nextElement)
//    }
//}
//
//
//
//extension GitIterator where Element == GitPointer {
//
//    init(
//        createIterator: GitPointer.Create,
//        configureIterator: (GitPointer.Configure)? = nil,
//        freeIterator: @escaping GitPointer.Free,
//        nextElement: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32,
//        configureElement: (GitPointer.Configure)? = nil,
//        freeElement: @escaping GitPointer.Free
//    ) throws {
//
//        try self.init(
//            createIterator: createIterator,
//            configureIterator: configureIterator,
//            freeIterator: freeIterator,
//            nextElement: { iterator in
//                try await GitPointer(
//                    create: iterator.create(nextElement),
//                    configure: configureElement,
//                    free: freeElement)
//            })
//    }
//}
