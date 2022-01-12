
import Clibgit2

extension Repository {

    public func diff(from tree1: Tree, to tree2: Tree) async throws -> Diff {
        let diff = try await GitPointer(
            create: repository.create(git_diff_tree_to_tree, tree1.tree.pointer, tree2.tree.pointer, nil),
            free: git_diff_free)
        return try Diff(diff)
    }
}
