
import Foundation
import GitKit
import XCTest

final class ReferenceTests: XCTestCase {

//    func testThrowsUnbornBranchError() throws {
//        try FileManager.default.withTemporaryDirectory { url in
//            let repository = try Repository(url: url)
//            XCTAssertThrowsError(try repository.head) { error in
//                XCTAssertEqual((error as? LibGit2Error)?.code, .unbornBranch)
//            }
//        }
//    }

    func testHead() async throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try await FileManager.default.withTemporaryDirectory { local in
            let repository = try Repository(local: local, remote: remote)
            let head = try await repository.head
            guard case let .branch(branch) = head else { XCTFail("Expected branch"); return }
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
        }
    }

//    func testRepositoryReferences() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//            let references = try repo.references
//            XCTAssertEqual(references.count, 5)
//            XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
//            XCTAssertEqual(try references.value(at: 0).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
//            XCTAssertEqual(try references.value(at: 0).debugDescription, "Branch(name: main, id: refs/heads/main, target: b1d2dba)")
//            XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try references.value(at: 1).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
//            XCTAssertEqual(try references.value(at: 1).debugDescription, "RemoteBranch(name: origin/HEAD, id: refs/remotes/origin/HEAD, target: b1d2dba)")
//            XCTAssertEqual(try references.value(at: 2).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try references.value(at: 2).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
//            XCTAssertEqual(try references.value(at: 2).debugDescription, "RemoteBranch(name: origin/main, id: refs/remotes/origin/main, target: b1d2dba)")
//            XCTAssertEqual(try references.value(at: 3).id, "refs/tags/1.0")
//            XCTAssertEqual(try references.value(at: 3).target.description, "17e26bc76cff375603e7173dac31e5183350e559")
//            XCTAssertEqual(try references.value(at: 3).debugDescription, "Tag(name: 1.0, id: refs/tags/1.0, target: 17e26bc)")
//            XCTAssertEqual(try references.value(at: 4).id, "refs/tags/lightweight-tag")
//            XCTAssertEqual(try references.value(at: 4).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
//            XCTAssertEqual(try references.value(at: 4).debugDescription, "Tag(name: lightweight-tag, id: refs/tags/lightweight-tag, target: b1d2dba)")
//        }
//    }

//    func testRemoveReferenceByType() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//
//            XCTAssertEqual(try repo.references.count, 5)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/heads/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 4).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(repo.branch(named: "main"))
//            XCTAssertEqual(try repo.references.count, 4)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(repo.remoteBranch(on: "origin", named: "HEAD"))
//            XCTAssertEqual(try repo.references.count, 3)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(repo.tag(named: "1.0"))
//            XCTAssertEqual(try repo.references.count, 2)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(repo.tag(named: "lightweight-tag"))
//            XCTAssertEqual(try repo.references.count, 1)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//        }
//    }

//    func testRemoveReferenceByTypeID() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//
//            XCTAssertEqual(try repo.references.count, 5)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/heads/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 4).id, "refs/tags/lightweight-tag")
//
//            guard case let .branch(branch) = try repo.references.value(at: 0) else { XCTFail("Expected branch"); return }
//            try repo.remove(branch.id)
//            XCTAssertEqual(try repo.references.count, 4)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/lightweight-tag")
//
//            guard case let .remoteBranch(remoteBranch) = try repo.references.value(at: 0) else { XCTFail("Expected remote"); return }
//            try repo.remove(remoteBranch.id)
//            XCTAssertEqual(try repo.references.count, 3)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/lightweight-tag")
//
//            guard case let .tag(annotatedTag) = try repo.references.value(at: 1) else { XCTFail("Expected annotated tag"); return }
//            try repo.remove(annotatedTag.id)
//            XCTAssertEqual(try repo.references.count, 2)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/lightweight-tag")
//
//            guard case let .tag(lightweightTag) = try repo.references.value(at: 1) else { XCTFail("Expected lightweight tag"); return }
//            try repo.remove(lightweightTag.id)
//            XCTAssertEqual(try repo.references.count, 1)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//        }
//    }

//    func testRemoveReferenceByID() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//
//            XCTAssertEqual(try repo.references.count, 5)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/heads/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 4).id, "refs/tags/lightweight-tag")
//
//            XCTAssertThrowsError(try repo.remove("refs/heads/not-here"))
//
//            try repo.remove("refs/heads/main")
//            XCTAssertEqual(try repo.references.count, 4)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/lightweight-tag")
//
//            try repo.remove("refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.count, 3)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/lightweight-tag")
//
//            try repo.remove("refs/tags/1.0")
//            XCTAssertEqual(try repo.references.count, 2)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/lightweight-tag")
//
//            try repo.remove("refs/tags/lightweight-tag")
//            XCTAssertEqual(try repo.references.count, 1)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//        }
//    }

//    func testRemoveReference() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//
//            XCTAssertEqual(try repo.references.count, 5)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/heads/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 4).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(try repo.reference(for: "refs/heads/main"))
//            XCTAssertEqual(try repo.references.count, 4)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/HEAD")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 3).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(try repo.reference(for: "refs/remotes/origin/HEAD"))
//            XCTAssertEqual(try repo.references.count, 3)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/1.0")
//            XCTAssertEqual(try repo.references.value(at: 2).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(try repo.reference(for: "refs/tags/1.0"))
//            XCTAssertEqual(try repo.references.count, 2)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//            XCTAssertEqual(try repo.references.value(at: 1).id, "refs/tags/lightweight-tag")
//
//            try repo.remove(try repo.reference(for: "refs/tags/lightweight-tag"))
//            XCTAssertEqual(try repo.references.count, 1)
//            XCTAssertEqual(try repo.references.value(at: 0).id, "refs/remotes/origin/main")
//        }
//    }
}
