import ProjectDescription

let workspace = Workspace(
    name: "SNUTT",
    projects: ["."],
    fileHeaderTemplate: .file("Tuist/FileHeaderTemplate.swift"),
    generationOptions: .options(
        enableAutomaticXcodeSchemes: false,
        autogeneratedWorkspaceSchemes: .disabled
    )
)
