import Foundation
import Git
import Testing

@Suite("Config")
struct ConfigTests {

  @Test func initURL() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)
    }
  }

  @Test func setString() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)

      try config.set("Value", for: "Test.Key")
      #expect(try Array(config.entries).count == 1)

      let entry = try #require(Array(config.entries).first)
      #expect(entry.name == "test.key")
      #expect(entry.value == "Value")
      #expect(entry.level == .local)
    }
  }

  @Test func getString() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)
      try config.set("Value", for: "Test.Key")
      #expect(try Array(config.entries).count == 1)
      #expect(try config.string(for: "Test.Key") == "Value")
    }
  }

  @Test func setInt() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)

      try config.set(123456, for: "Some.Number")

      #expect(try Array(config.entries).count == 1)
      let entry = try #require(Array(config.entries).first)
      #expect(entry.name == "some.number")
      #expect(entry.value == "123456")
      #expect(entry.level == .local)
    }
  }

  @Test func getInt() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)
      try config.set(123456, for: "Some.Number")
      #expect(try Array(config.entries).count == 1)
      #expect(try config.integer(for: "Some.Number") == 123456)
    }
  }

  @Test func setBool() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)

      try config.set(true, for: "Some.Bool")

      #expect(try Array(config.entries).count == 1)
      let entry = try #require(Array(config.entries).first)
      #expect(entry.name == "some.bool")
      #expect(entry.value == "true")
      #expect(entry.level == .local)
    }
  }

  @Test func getBool() throws {
    try FileManager.default.withTemporaryDirectory { local in
      let config = try Config(url: local.appending(path: "test-config"))
      #expect(try Array(config.entries).count == 0)
      try config.set(true, for: "Some.Bool")
      #expect(try Array(config.entries).count == 1)
      #expect(try config.boolean(for: "Some.Bool") == true)
    }
  }

  @Test func level() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository.clone(remote, to: local)
      let config = try repo.config

      let old = try Set(config.entries)

      do {
        let local = try config.level(.local)
        let old = try Set(local.entries)
        try local.set("Test Value", for: "Test.Key")
        let new = try Set(local.entries).subtracting(old)

        #expect(new.count == 1)
        let first = try #require(new.first)
        #expect(first.name == "test.key")
        #expect(first.value == "Test Value")
        #expect(first.level == .local)
      }

      let new = try Set(config.entries).subtracting(old)

      #expect(new.count == 1)
      let first = try #require(new.first)
      #expect(first.name == "test.key")
      #expect(first.value == "Test Value")
      #expect(first.level == .local)
    }
  }

  @Test func levelDescription() {
    #expect(Config.Level.programData.description == "ProgramData")
    #expect(Config.Level.system.description == "System")
    #expect(Config.Level.xdg.description == "XDG")
    #expect(Config.Level.global.description == "Global")
    #expect(Config.Level.local.description == "Local")
    #expect(Config.Level.app.description == "App")
    #expect(Config.Level.highest.description == "Highest")
  }
}
