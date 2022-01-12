
import Foundation
import GitKit
import XCTest

//private func AssertEqualResolvingSymlinks(
//    _ expression1: @autoclosure () throws -> URL?,
//    _ expression2: @autoclosure () throws -> URL?,
//    file: StaticString = #filePath,
//    line: UInt = #line
//) rethrows {
//    XCTAssertEqual(try expression1()?.resolvingSymlinksInPath(),
//                   try expression2()?.resolvingSymlinksInPath(),
//                   file: file,
//                   line: line)
//}
//
//final class RepositoryTests: XCTestCase {
//
//    func testClone() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            let repo = try Repository(local: local, remote: remote)
//            AssertEqualResolvingSymlinks(repo.workingDirectory, local)
//        }
//    }
//
//    func testCreate() throws {
//        try FileManager.default.withTemporaryDirectory { url in
//            let repo = try Repository(url: url)
//            AssertEqualResolvingSymlinks(repo.workingDirectory, url)
//        }
//    }
//
//    func testCreateBare() throws {
//        try FileManager.default.withTemporaryDirectory { url in
//            let bare = try Repository(url: url, options: .create(isBare: true))
//            XCTAssertNil(bare.workingDirectory)
//        }
//    }
//
//    func testCreateNotBare() throws {
//        try FileManager.default.withTemporaryDirectory { url in
//            let repo = try Repository(url: url, options: .create(isBare: false))
//            AssertEqualResolvingSymlinks(repo.workingDirectory, url)
//        }
//    }
//
//    func testOpen() throws {
//        let remote = try Bundle.module.url(forRepository: "Test.git")
//        try FileManager.default.withTemporaryDirectory { local in
//            XCTAssertNoThrow(try Repository(local: local, remote: remote))
//            let repo = try Repository(url: local, options: .open)
//            AssertEqualResolvingSymlinks(repo.workingDirectory, local)
//        }
//    }
//}
