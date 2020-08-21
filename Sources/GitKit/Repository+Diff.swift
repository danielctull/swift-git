
import Clibgit2

extension Repository {

    public func diff(from tree1: Tree, to tree2: Tree) throws -> Diff {
        let diff = try GitPointer(create: { git_diff_tree_to_tree($0, repository.pointer, tree1.tree.pointer, tree2.tree.pointer, nil) },
                                  free: git_diff_free)
        return try Diff(diff)
    }
}
