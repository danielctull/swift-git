
import Clibgit2

@globalActor
public struct GitActor {

    public actor ActorType {
        init() { git_libgit2_init() }
        deinit { git_libgit2_shutdown() }

        func with<Value>(_ pointer: GitPointer, perform task: (OpaquePointer) async throws -> Value) async rethrows -> Value {
            try await task(pointer.pointer)
        }
    }

    public static let shared: ActorType = ActorType()
}
