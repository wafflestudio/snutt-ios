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
                .target(name: "AnalyticsInterface"),
                .target(name: "TimetableUIComponents"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "ReviewsInterface"),
                .target(name: "NotificationsInterface"),
                .target(name: "VacancyInterface"),
                .target(name: "AuthInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "SwiftUIUtility"),
                .target(name: "FoundationUtility"),
                .target(name: "SharedUIComponents"),
                .target(name: "SharedUIMapKit"),
                .external(name: "Dependencies"),
                .external(name: "SnapKit"),
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
                .target(name: "AnalyticsInterface"),
                .target(name: "AuthInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "SharedUIWebKit"),
                .target(name: "DependenciesUtility"),
                .target(name: "FoundationUtility"),
                .external(name: "Dependencies"),
                .external(name: "DependenciesAdditions"),
                .external(name: "MemberwiseInit"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "FacebookCore"),
                .external(name: "FacebookLogin"),
                .external(name: "GoogleSignInSwift"),
                .external(name: "GoogleSignIn"),
            ]
        ),
        .module(
            name: "Analytics",
            category: .feature,
            previewable: false,
            dependencies: [
                .target(name: "AnalyticsInterface"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "Popup",
            category: .feature,
            dependencies: [
                .target(name: "AnalyticsInterface"),
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
                .target(name: "AnalyticsInterface"),
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
                .target(name: "AnalyticsInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "VacancyInterface"),
                .target(name: "AuthInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "SharedUIWebKit"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "Vacancy",
            category: .feature,
            dependencies: [
                .target(name: "AnalyticsInterface"),
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
            previewable: false,
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
                .target(name: "AnalyticsInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "AuthInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "SharedUIWebKit"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
            ]
        ),
        .module(
            name: "APIClient",
            category: .feature,
            previewable: false,
            dependencies: [
                .target(name: "APIClientInterface"),
                .external(name: "OpenAPIRuntime"),
                .external(name: "OpenAPIURLSession"),
            ],
        ),
        .module(
            name: "Reviews",
            category: .feature,
            dependencies: [
                .target(name: "AnalyticsInterface"),
                .target(name: "SharedUIWebKit"),
                .target(name: "AuthInterface"),
                .target(name: "ReviewsInterface"),
                .target(name: "SharedAppMetadata"),
                .external(name: "Dependencies"),
            ]
        ),
        .module(
            name: "Friends",
            category: .feature,
            dependencies: [
                .target(name: "AnalyticsInterface"),
                .target(name: "APIClientInterface"),
                .target(name: "AuthInterface"),
                .target(name: "FriendsInterface"),
                .target(name: "TimetableInterface"),
                .target(name: "ThemesInterface"),
                .target(name: "SharedUIComponents"),
                .target(name: "FoundationUtility"),
                .target(name: "SwiftUIUtility"),
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKShare"),
                .external(name: "KakaoSDKTemplate"),
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
            name: "AnalyticsInterface",
            category: .featureInterface,
            dependencies: [
                .external(name: "Dependencies"),
                .external(name: "MemberwiseInit"),
                .external(name: "Spyable"),
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
        .module(
            name: "ReviewsInterface",
            category: .featureInterface,
            dependencies: [
                .external(name: "Dependencies")
            ]
        ),
        .module(
            name: "FriendsInterface",
            category: .featureInterface,
            dependencies: []
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
            name: "SharedUIWebKit",
            category: .shared(ui: true),
            dependencies: [
                .target(name: "SharedAppMetadata")
            ]
        ),
        .module(
            name: "SharedUIMapKit",
            category: .shared(ui: true),
            dependencies: []
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
        // Define dependencies exclusively for the main target.
        .external(name: "FirebaseCore"),
        .external(name: "FirebaseMessaging"),
        .external(name: "FirebaseAnalytics"),
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
