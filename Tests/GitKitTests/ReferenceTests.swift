
import Foundation
import GitKit
import XCTest

final class ReferenceTests: XCTestCase {

    func testThrowsUnbornBranchError() throws {
        try FileManager.default.withTemporaryDirectory { url in
            let repository = try Repository(url: url)
            XCTAssertThrowsError(try repository.head()) { error in
                XCTAssertEqual((error as? LibGit2Error)?.code, .unbornBranch)
            }
        }
    }

    func testHead() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repository = try Repository(local: local, remote: remote)
            let head = try repository.head()
            guard case let .branch(branch) = head else { XCTFail("Expected branch"); return }
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
        }
    }

    func testRepositoryReferences() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let references = try repo.references()
            XCTAssertEqual(references.count, 4)
            XCTAssertEqual(try references.value(at: 0).id, "refs/heads/main")
            XCTAssertEqual(try references.value(at: 0).objectID.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 0).debugDescription, "Branch(name: main, id: refs/heads/main, objectID: b1d2dba)")
            XCTAssertEqual(try references.value(at: 1).id, "refs/remotes/origin/main")
            XCTAssertEqual(try references.value(at: 1).objectID.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 1).debugDescription, "RemoteBranch(name: origin/main, id: refs/remotes/origin/main, objectID: b1d2dba)")
            XCTAssertEqual(try references.value(at: 2).id, "refs/tags/1.0")
            XCTAssertEqual(try references.value(at: 2).objectID.description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(try references.value(at: 2).debugDescription, "Tag(name: 1.0, id: refs/tags/1.0, target: 17e26bc)")
            XCTAssertEqual(try references.value(at: 3).id, "refs/tags/lightweight-tag")
            XCTAssertEqual(try references.value(at: 3).objectID.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try references.value(at: 3).debugDescription, "Tag(name: lightweight-tag, id: refs/tags/lightweight-tag, target: b1d2dba)")
        }
    }
}
