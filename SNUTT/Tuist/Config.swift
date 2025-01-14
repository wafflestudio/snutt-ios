import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .upToNextMajor("16.0.0"),
    swiftVersion: "6.0.0",
    generationOptions: .options(enforceExplicitDependencies: true)
)
