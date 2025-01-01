import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")
private let category = ModuleCategory.featureInterface
private let template = Template(
    description: "A template for a new feature interface module.",
    attributes: [
        name,
    ],
    items: [
        .file(path: "Modules/\(category.directoryName)/\(name)/Sources/\(name).swift", templatePath: "FeatureInterface.stencil"),
    ]
)
