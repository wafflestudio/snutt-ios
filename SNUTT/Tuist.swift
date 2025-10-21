import ProjectDescription

let config = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .list([.upToNextMajor("16.0.0"), .upToNextMajor("26.0.0")]),
        swiftVersion: "6.1.0",
        plugins: [],
        generationOptions: .options(disableSandbox: true),
        installOptions: .options()
    )
)
