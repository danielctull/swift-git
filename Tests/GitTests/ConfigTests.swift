import Foundation
import Git
import Testing

@Suite("Config")
struct ConfigTests {

  @Test(.scratchDirectory(.random))
  func initURL() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)
  }

  @Test(.scratchDirectory(.random))
  func setString() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)

    try config.set("Value", for: "Test.Key")
    #expect(try Array(config.entries).count == 1)

    let entry = try #require(Array(config.entries).first)
    #expect(entry.name == "test.key")
    #expect(entry.value == "Value")
    #expect(entry.level == .local)

  }

  @Test(.scratchDirectory(.random))
  func getString() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)
    try config.set("Value", for: "Test.Key")
    #expect(try Array(config.entries).count == 1)
    #expect(try config.string(for: "Test.Key") == "Value")
  }

  @Test(.scratchDirectory(.random))
  func setInt() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)

    try config.set(123456, for: "Some.Number")

    #expect(try Array(config.entries).count == 1)
    let entry = try #require(Array(config.entries).first)
    #expect(entry.name == "some.number")
    #expect(entry.value == "123456")
    #expect(entry.level == .local)
  }

  @Test(.scratchDirectory(.random))
  func getInt() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)
    try config.set(123456, for: "Some.Number")
    #expect(try Array(config.entries).count == 1)
    #expect(try config.integer(for: "Some.Number") == 123456)
  }

  @Test(.scratchDirectory(.random))
  func setBool() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)

    try config.set(true, for: "Some.Bool")

    #expect(try Array(config.entries).count == 1)
    let entry = try #require(Array(config.entries).first)
    #expect(entry.name == "some.bool")
    #expect(entry.value == "true")
    #expect(entry.level == .local)
  }

  @Test(.scratchDirectory(.random))
  func getBool() throws {
    let config = try Config(
      url: URL.scratchDirectory.appending(path: "test-config")
    )
    #expect(try Array(config.entries).count == 0)
    try config.set(true, for: "Some.Bool")
    #expect(try Array(config.entries).count == 1)
    #expect(try config.boolean(for: "Some.Bool") == true)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func level() throws {
    let repo = try Repository.clone(.repository, to: .scratchDirectory)
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
