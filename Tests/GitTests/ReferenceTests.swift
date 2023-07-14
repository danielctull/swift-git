
import Foundation
import Git
import XCTest

@GitActor
final class ReferenceTests: XCTestCase {

    func testThrowsUnbornBranchError() throws {
        try FileManager.default.withTemporaryDirectory { url in
            let repository = try Repository(url: url)
            XCTAssertThrowsError(try repository.head) { error in
                XCTAssertEqual((error as? GitError)?.code, .unbornBranch)
            }
        }
    }

    func testHead() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repository = try Repository(local: local, remote: remote)
            let head = try repository.head
            guard case let .branch(branch) = head else { XCTFail("Expected branch"); return }
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.reference, "refs/heads/main")
        }
    }

    func testRepositoryReferences() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let references = try Array(repo.references)
            XCTAssertEqual(references.count, 5)
            XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
            XCTAssertEqual(try references.value(at: 0).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 0).debugDescription, "Branch(name: main, reference: refs/heads/main, target: b1d2dba)")
            XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/HEAD")
            XCTAssertEqual(try references.value(at: 1).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 1).debugDescription, "RemoteBranch(name: origin/HEAD, reference: refs/remotes/origin/HEAD, target: b1d2dba)")
            XCTAssertEqual(try references.value(at: 2).id, "refs/remotes/origin/main")
            XCTAssertEqual(try references.value(at: 2).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 2).debugDescription, "RemoteBranch(name: origin/main, reference: refs/remotes/origin/main, target: b1d2dba)")
            XCTAssertEqual(try references.value(at: 3).id, "refs/tags/1.0")
            XCTAssertEqual(try references.value(at: 3).target.description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(try references.value(at: 3).debugDescription, "Tag(name: 1.0, reference: refs/tags/1.0, target: 17e26bc)")
            XCTAssertEqual(try references.value(at: 4).id, "refs/tags/lightweight-tag")
            XCTAssertEqual(try references.value(at: 4).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 4).debugDescription, "Tag(name: lightweight-tag, reference: refs/tags/lightweight-tag, target: b1d2dba)")
        }
    }

    func testDelete() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 5)
                XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 2).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 4).id, "refs/tags/lightweight-tag")
                try repo.delete(references.value(at: 0))
            }

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 4)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/lightweight-tag")
                try repo.delete(references.value(at: 0))
            }

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 3)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/lightweight-tag")
                try repo.delete(references.value(at: 1))
            }

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 2)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/lightweight-tag")
                try repo.delete(references.value(at: 1))
            }

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 1)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
            }
        }
    }

    func testRemoveReferenceByID() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 5)
                XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 2).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 4).id, "refs/tags/lightweight-tag")
            }

            XCTAssertThrowsError(try repo.remove("refs/heads/not-here"))

            do {
                try repo.remove("refs/heads/main")
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 4)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove("refs/remotes/origin/HEAD")
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 3)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove("refs/tags/1.0")
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 2)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove("refs/tags/lightweight-tag")
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 1)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
            }
        }
    }

    func testRemoveReference() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)

            do {
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 5)
                XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 2).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 4).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove(try repo.reference(for: "refs/heads/main"))
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 4)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/HEAD")
                XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 3).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove(try repo.reference(for: "refs/remotes/origin/HEAD"))
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 3)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/1.0")
                XCTAssertEqual(try references.value(at: 2).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove(try repo.reference(for: "refs/tags/1.0"))
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 2)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
                XCTAssertEqual(try references.value(at: 1).id, "refs/tags/lightweight-tag")
            }

            do {
                try repo.remove(try repo.reference(for: "refs/tags/lightweight-tag"))
                let references = try Array(repo.references)
                XCTAssertEqual(references.count, 1)
                XCTAssertEqual(try references.value(at: 0).id, "refs/remotes/origin/main")
            }
        }
    }
}
