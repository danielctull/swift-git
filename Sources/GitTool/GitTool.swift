import ArgumentParser

@main
struct GitTool: ParsableCommand {

  static let configuration = CommandConfiguration(subcommands: [
    Status.self
  ])
}
