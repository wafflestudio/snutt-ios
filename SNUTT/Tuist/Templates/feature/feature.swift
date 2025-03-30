import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")
private let category = ModuleCategory.feature
private let template = Template(
    description: "A template for a new feature module.",
    attributes: [
        name,
    ],
    items: [
        .file(
            path: "Modules/\(category.directoryName)/\(name)/Sources/\(name).swift",
            templatePath: "Feature.stencil"
        ),
        .file(
            path: "Modules/\(category.directoryName)/\(name)/Tests/\(name)Tests.swift",
            templatePath: "FeatureTests.stencil"
        ),
        .file(
            path: "Modules/\(category.directoryName)/\(name)/Resources/Assets.xcassets/Contents.json",
            templatePath: "Contents.json.stencil"
        ),
        .file(
            path: "Modules/\(category.directoryName)/\(name)/Resources/Base.lproj/Localizable.strings",
            templatePath: "Localizable.strings.stencil"
        ),
        .file(
            path: "Modules/\(category.directoryName)/\(name)/Resources/en.lproj/Localizable.strings",
            templatePath: "Localizable.strings.stencil"
        ),
    ]
)
