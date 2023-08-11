
import Foundation
import Git
import XCTest

@GitActor
final class ConfigTests: XCTestCase {

    func testInit() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)
        }
    }

    func testSetString() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)

            try config.set("Value", for: "Test.Key")
            XCTAssertEqual(try Array(config.items).count, 1)

            let item = try XCTUnwrap(Array(config.items).first)
            XCTAssertEqual(item.name, "test.key")
            XCTAssertEqual(item.value, "Value")
            XCTAssertEqual(item.level, .local)
        }
    }

    func testGetString() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)
            try config.set("Value", for: "Test.Key")
            XCTAssertEqual(try Array(config.items).count, 1)
            XCTAssertEqual(try config.string(for: "Test.Key"), "Value")
        }
    }

    func testSetInt() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)

            try config.set(123456, for: "Some.Number")

            XCTAssertEqual(try Array(config.items).count, 1)
            let item = try XCTUnwrap(Array(config.items).first)
            XCTAssertEqual(item.name, "some.number")
            XCTAssertEqual(item.value, "123456")
            XCTAssertEqual(item.level, .local)
        }
    }

    func testGetInt() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)
            try config.set(123456, for: "Some.Number")
            XCTAssertEqual(try Array(config.items).count, 1)
            XCTAssertEqual(try config.integer(for: "Some.Number"), 123456)
        }
    }

    func testSetBool() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)

            try config.set(true, for: "Some.Bool")

            XCTAssertEqual(try Array(config.items).count, 1)
            let item = try XCTUnwrap(Array(config.items).first)
            XCTAssertEqual(item.name, "some.bool")
            XCTAssertEqual(item.value, "true")
            XCTAssertEqual(item.level, .local)
        }
    }

    func testGetBool() throws {
        try FileManager.default.withTemporaryDirectory { local in
            let config = try Config(url: local.appending(path: "test-config"))
            XCTAssertEqual(try Array(config.items).count, 0)
            try config.set(true, for: "Some.Bool")
            XCTAssertEqual(try Array(config.items).count, 1)
            XCTAssertEqual(try config.boolean(for: "Some.Bool"), true)
        }
    }

    func testLevel() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in

            let repo = try Repository(local: local, remote: remote)
            let config = try repo.config

            let old = try Set(config.items)

            do {
                let local = try config.level(.local)
                let old = try Set(local.items)
                try local.set("Test Value", for: "Test.Key")
                let new = try Set(local.items).subtracting(old)

                XCTAssertEqual(new.count, 1)
                let first = try XCTUnwrap(new.first)
                XCTAssertEqual(first.name, "test.key")
                XCTAssertEqual(first.value, "Test Value")
                XCTAssertEqual(first.level, .local)
            }

            let new = try Set(config.items).subtracting(old)

            XCTAssertEqual(new.count, 1)
            let first = try XCTUnwrap(new.first)
            XCTAssertEqual(first.name, "test.key")
            XCTAssertEqual(first.value, "Test Value")
            XCTAssertEqual(first.level, .local)
        }
    }

    func testLevelDescription() {
        XCTAssertEqual(Config.Level.programData.description, "ProgramData")
        XCTAssertEqual(Config.Level.system.description, "System")
        XCTAssertEqual(Config.Level.xdg.description, "XDG")
        XCTAssertEqual(Config.Level.global.description, "Global")
        XCTAssertEqual(Config.Level.local.description, "Local")
        XCTAssertEqual(Config.Level.app.description, "App")
        XCTAssertEqual(Config.Level.highest.description, "Highest")
    }
}
