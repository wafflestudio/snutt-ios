import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")
private let category = ModuleCategory.shared(ui: false)
private let template = Template(
    description: "A template for a new feature module.",
    attributes: [
        name,
    ],
    items: [
        .file(path: "Modules/\(category.directoryName)/\(name)/Sources/\(name).swift", templatePath: "Shared.stencil"),
        .file(path: "Modules/\(category.directoryName)/\(name)/Tests/\(name)Tests.swift", templatePath: "SharedTests.stencil"),
    ]
)