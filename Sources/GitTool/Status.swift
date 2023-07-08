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

    let index: [Git.Status: String] = [
      .indexNew: "new file:   ",
      .indexDeleted: "deleted:    ",
      .indexRenamed: "renamed:    ",
      .indexModified: "modified:   ",
      .indexTypeChange: "type change:",
    ]

    let workingDirectory: [Git.Status: String] = [
      .workingTreeNew: "new file:   ",
      .workingTreeDeleted: "deleted:    ",
      .workingTreeRenamed: "renamed:    ",
      .workingTreeModified: "modified:   ",
      .workingTreeTypeChange: "type change:",
      .workingTreeUnreadable: "unreadable: ",
    ]

    func printFiles(
      title: String,
      delta: (StatusEntry) -> Diff.Delta?,
      status: [Git.Status: String]
    ) {

      let entries: [(String, Diff.File)] = entries.compactMap { entry in
        guard let file = delta(entry)?.file else { return nil }

        for (status, value) in status {
          if entry.status.contains(status) {
            return (value, file)
          }
        }

        return nil
      }

      if !entries.isEmpty {
        print("")
        print(title)
        for entry in entries {
          print("        \(entry.0)\(entry.1.path)")
        }
      }
    }

    printFiles(
      title: "Changes to be committed:",
      delta: \.headToIndex,
      status: index
    )

    printFiles(
      title: "Changes not staged for commit:",
      delta: \.indexToWorkingDirectory,
      status: workingDirectory
    )
  }
}
