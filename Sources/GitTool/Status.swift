import ArgumentParser
import Foundation
import Git

struct NoCurrentDirectoryURL: Error {}

extension Diff.Delta {

  var file: Diff.File? { to ?? from }
}

struct Status: ParsableCommand {

  static let configuration = CommandConfiguration(commandName: "status")

  func run() throws {

    guard let directory = Process().currentDirectoryURL else {
      throw NoCurrentDirectoryURL()
    }

    let repo = try Repository(url: directory)

    switch try repo.head {
    case .branch(let branch):
      print("On branch \(branch.name)")
    default:
      print("Unknown state")
    }

    let entries = try repo.status

    let indexStatus: [Git.Status: String] = [
      .indexNew: "new file:   ",
      .indexDeleted: "deleted:    ",
      .indexRenamed: "renamed:    ",
      .indexModified: "modified:   ",
      .indexTypeChange: "type change:",
    ]

    let index: [(String, Diff.File)] = entries.compactMap { entry in
      guard let file = entry.headToIndex?.file else { return nil }

      for (status, value) in indexStatus {
        if entry.status.contains(status) {
          return (value, file)
        }
      }

      return nil
    }

    let workingDirectoryStatus: [Git.Status: String] = [
      .workingTreeNew: "new file:   ",
      .workingTreeDeleted: "deleted:    ",
      .workingTreeRenamed: "renamed:    ",
      .workingTreeModified: "modified:   ",
      .workingTreeTypeChange: "type change:",
      .workingTreeUnreadable: "unreadable: ",
    ]

    let workingDirectory: [(String, Diff.File)] = entries.compactMap { entry in

      guard let file = entry.indexToWorkingDirectory?.file else { return nil }

      for (status, value) in workingDirectoryStatus {
        if entry.status.contains(status) {
          return (value, file)
        }
      }

      return nil
    }

    func printFiles(_ title: String, files: [(String, Diff.File)]) {
      if !files.isEmpty {
        print("")
        print(title)
        for entry in files {
          print("        \(entry.0)\(entry.1.path)")
        }
      }
    }

    printFiles("Changes to be committed:", files: index)
    printFiles("Changes not staged for commit:", files: workingDirectory)
  }
}
