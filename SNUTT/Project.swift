import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    name: "SNUTT",
    destinations: .iOS,
    swiftPackages: [
        .remote(url: "https://github.com/apple/swift-openapi-generator", requirement: .upToNextMajor(from: "1.0.0")),
    ],
    moduleDependencies: [
        // Feature
        .module(
            name: "Timetable",
            category: .feature,
            dependencies: [
                .target(name: "TimetableUIComponents"),
                .target(name: "TimetableInterface"),
                .target(name: "SwiftUIUtility"),
                .target(name: "FoundationUtility"),
                .target(name: "AuthInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "SharedUIComponents"),
                .external(name: "Dependencies"),
                .external(name: "SwiftUIIntrospect"),
            ]
        ),
        .module(
            name: "TimetableUIComponents",
            category: .feature,
            dependencies: [
                .target(name: "TimetableInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "Auth",
            category: .feature,
            dependencies: [
                .target(name: "AuthInterface"),
                .target(name: "SharedUIComponents"),
            ]
        ),
        .module(
            name: "AuthInterface",
            category: .featureInterface,
            dependencies: [
                .target(name: "APIClientInterface"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "Popup",
            category: .feature,
            dependencies: [
                .target(name: "APIClientInterface"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
                .external(name: "Spyable"),
            ]
        ),
        .module(
            name: "Notifications",
            category: .feature,
            dependencies: [
                .target(name: "APIClientInterface"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        // FeatureInterface
        .module(
            name: "TimetableInterface",
            category: .featureInterface,
            dependencies: [
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Spyable"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "APIClientInterface",
            category: .featureInterface,
            dependencies: [
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
                .package(product: "OpenAPIGenerator", type: .plugin),
                .external(name: "Dependencies"),
                .target(name: "SharedAppMetadata"),
                .external(name: "Spyable"),
            ],
            additionalResources: ["OpenAPI/**", "Modules/Feature/APIClientInterface/Resources/**"]
        ),
        // Shared
        .module(
            name: "SharedUIComponents",
            category: .shared(ui: true),
            dependencies: [
                .target(name: "SwiftUIUtility"),
                .target(name: "UIKitUtility"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "SharedAppMetadata",
            category: .shared(ui: false),
            dependencies: [
                .external(name: "Dependencies"),
                .target(name: "DependenciesUtility"),
            ]
        ),
        // Utility
        .module(name: "DependenciesUtility", category: .utility(ui: false), dependencies: [
            .external(name: "Dependencies"),
            .external(name: "DependenciesAdditions"),
        ]),
        .module(name: "SwiftUIUtility", category: .utility(ui: true), dependencies: []),
        .module(name: "UIKitUtility", category: .utility(ui: true), dependencies: [
            .external(name: "SnapKit"),
        ]),
        .module(name: "FoundationUtility", category: .utility(ui: false), dependencies: []),
    ],
    externalDependencies: [],
    widgetDependencies: [
        .target(name: "TimetableInterface"),
        .target(name: "TimetableUIComponents"),
        .target(name: "FoundationUtility"),
        .target(name: "DependenciesUtility"),
        .external(name: "Dependencies"),
        .external(name: "DependenciesAdditions"),
    ],
    deploymentTargets: .iOS("17.0.0")
)
