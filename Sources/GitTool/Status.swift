import ArgumentParser
import Foundation
import Git

struct NoCurrentDirectoryURL: Error {}

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

    let headToIndex = entries.filter({ $0.headToIndex != nil })
    if !headToIndex.isEmpty {
      print("")
      print("Changes to be committed:")
      for entry in headToIndex {
        let delta = entry.headToIndex!
        guard let file = delta.to ?? delta.from else { continue }

        if entry.status.contains(.indexNew) {
          print("        new file:   " + file.path)
        } else if entry.status.contains(.indexDeleted) {
          print("        deleted:    " + file.path)
        } else if entry.status.contains(.indexRenamed) {
          print("        renamed:    " + file.path)
        } else if entry.status.contains(.indexModified) {
          print("        modified:   " + file.path)
        } else if entry.status.contains(.indexTypeChange) {
          print("        type change:" + file.path)
        }
      }
    }

    let indexToWorkingDirectory = entries.filter({
      $0.indexToWorkingDirectory != nil
    })
    if !indexToWorkingDirectory.isEmpty {
      print("")
      print("Changes not staged for commit:")
      for entry in indexToWorkingDirectory {
        let delta = entry.indexToWorkingDirectory!
        guard let file = delta.to ?? delta.from else { continue }

        if entry.status.contains(.workingTreeNew) {
          print("        new file:   " + file.path)
        } else if entry.status.contains(.workingTreeDeleted) {
          print("        deleted:    " + file.path)
        } else if entry.status.contains(.workingTreeRenamed) {
          print("        renamed:    " + file.path)
        } else if entry.status.contains(.workingTreeModified) {
          print("        modified:   " + file.path)
        } else if entry.status.contains(.workingTreeUnreadable) {
          print("        unreadable: " + file.path)
        } else if entry.status.contains(.workingTreeTypeChange) {
          print("        type change:" + file.path)
        }
      }
    }
  }
}
