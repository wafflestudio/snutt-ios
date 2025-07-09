import ProjectDescription

let config = Tuist(project: .tuist(
    compatibleXcodeVersions: .upToNextMajor("16.0.0"),
    swiftVersion: "6.0.0",
    plugins: [],
    generationOptions: .options(disableSandbox: true),
    installOptions: .options()
))
