import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    name: "SNUTT",
    destinations: .iOS,
    swiftPackages: [],
    moduleDependencies: [
        // Feature
        .module(
            name: "Timetable",
            category: .feature,
            dependencies: [
                .target(name: "TimetableUIComponents"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "NotificationsInterface"),
                .target(name: "VacancyInterface"),
                .target(name: "SwiftUIUtility"),
                .target(name: "FoundationUtility"),
                .target(name: "AuthInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "SharedUIComponents"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "TimetableUIComponents",
            category: .feature,
            dependencies: [
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
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
                .target(name: "APIClientInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "DependenciesUtility"),
                .external(name: "Dependencies"),
                .external(name: "DependenciesAdditions"),
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
                .target(name: "SharedUIComponents"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
                .external(name: "Spyable"),
            ]
        ),
        .module(
            name: "Notifications",
            category: .feature,
            dependencies: [
                .target(name: "NotificationsInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "Settings",
            category: .feature,
            dependencies: [
                .target(name: "APIClientInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "VacancyInterface"),
                .target(name: "TimetableUIComponents"),
                .target(name: "AuthInterface"),
                .target(name: "SharedUIComponents"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "Vacancy",
            category: .feature,
            dependencies: [
                .target(name: "VacancyInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "ConfigsInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "Configs",
            category: .feature,
            dependencies: [
                .target(name: "ConfigsInterface"),
                .target(name: "APIClientInterface"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "Themes",
            category: .feature,
            dependencies: [
                .target(name: "APIClientInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "APIClient",
            category: .feature,
            dependencies: [
                .target(name: "APIClientInterface"),
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
            ]
        ),
        // FeatureInterface
        .module(
            name: "TimetableInterface",
            category: .featureInterface,
            dependencies: [
                .target(name: "APIClientInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Spyable"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "VacancyInterface",
            category: .featureInterface,
            dependencies: [
                .target(name: "APIClientInterface"),
                .external(name: "Spyable"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "NotificationsInterface",
            category: .featureInterface,
            dependencies: []
        ),
        .module(
            name: "ConfigsInterface",
            category: .featureInterface,
            dependencies: [
                .external(name: "Spyable"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "ThemesInterface",
            category: .featureInterface,
            dependencies: [
                .target(name: "SwiftUIUtility"),
                .external(name: "Spyable"),
                .external(name: "MemberwiseInit"),
                .external(name: "Dependencies"),
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
            name: "APIClientInterface",
            category: .featureInterface,
            productType: .framework,
            dependencies: [
                // DO NOT add any other feature (interface) here.
                .target(name: "SharedAppMetadata"),
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
                .external(name: "Dependencies"),
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
        .module(
            name: "DependenciesUtility",
            category: .utility(ui: false),
            dependencies: [
                .external(name: "Dependencies"),
                .external(name: "DependenciesAdditions"),
            ]
        ),
        .module(
            name: "SwiftUIUtility",
            category: .utility(ui: true),
            dependencies: [
                .external(name: "SwiftUIIntrospect")
            ]
        ),
        .module(
            name: "UIKitUtility",
            category: .utility(ui: true),
            dependencies: [
                .external(name: "SnapKit")
            ]
        ),
        .module(name: "FoundationUtility", category: .utility(ui: false), dependencies: []),
    ],
    externalDependencies: [
        .external(name: "FirebaseCore"),
        .external(name: "FirebaseMessaging"),
        .external(name: "KakaoMapsSDK-SPM"),
    ],
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
