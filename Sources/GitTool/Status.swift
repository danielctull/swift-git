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

    let index: [(String, Diff.File)] = entries.compactMap { entry in

      guard let file = entry.headToIndex?.file else { return nil }

      if entry.status.contains(.indexNew) {
        return ("new file:   ", file)
      } else if entry.status.contains(.indexDeleted) {
        return ("deleted:    ", file)
      } else if entry.status.contains(.indexRenamed) {
        return ("renamed:    ", file)
      } else if entry.status.contains(.indexModified) {
        return ("modified:   ", file)
      } else if entry.status.contains(.indexTypeChange) {
        return ("type change:", file)
      } else {
        return nil
      }
    }

    let workingDirectory: [(String, Diff.File)] = entries.compactMap { entry in

      guard let file = entry.indexToWorkingDirectory?.file else { return nil }

      if entry.status.contains(.workingTreeNew) {
        return ("new file:   ", file)
      } else if entry.status.contains(.workingTreeDeleted) {
        return ("deleted:    ", file)
      } else if entry.status.contains(.workingTreeRenamed) {
        return ("renamed:    ", file)
      } else if entry.status.contains(.workingTreeModified) {
        return ("modified:   ", file)
      } else if entry.status.contains(.workingTreeUnreadable) {
        return ("unreadable: ", file)
      } else if entry.status.contains(.workingTreeTypeChange) {
        return ("type change:", file)
      } else {
        return nil
      }
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
