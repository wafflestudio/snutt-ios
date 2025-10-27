import Foundation
import ProjectDescription

let domain = "com.wafflestudio"

// MARK: - Version Constants
let marketingVersion: Plist.Value = "1.0.0"
let buildNumber: Plist.Value = "1"

extension Project {
    public static func app(
        name: String,
        destinations: Destinations,
        swiftPackages: [Package],
        moduleDependencies: [ModuleDependency],
        externalDependencies: [TargetDependency],
        widgetDependencies: [TargetDependency],
        deploymentTargets: DeploymentTargets
    ) -> Project {
        let mainTargetDependencies: [TargetDependency] =
            moduleDependencies
            .map { .target(name: $0.name) } + externalDependencies
        let widgetTarget = makeWidgetTarget(
            name: name,
            deploymentTargets: deploymentTargets,
            dependencies: widgetDependencies
        )
        let mainTargets = makeAppTargets(
            name: name,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            dependencies: mainTargetDependencies + [.target(name: widgetTarget.name)]
        )
        let frameworkTargets = moduleDependencies.map {
            makeFrameworkTargets(module: $0, destinations: destinations, deploymentTargets: deploymentTargets)
        }
        let allTargets = [mainTargets] + frameworkTargets
        let testTargets = allTargets.compactMap { _, testTarget in testTarget }
        let schemes =
            makeSchemes(name: name) + [makeModuleTestsScheme(testTargets: testTargets)]
            + makePreviewSchemes(
                moduleDependencies: moduleDependencies
            )
        return Project(
            name: name,
            organizationName: "wafflestudio.com",
            options: .options(automaticSchemesOptions: .disabled),
            packages: swiftPackages,
            settings: makeSettings(),
            targets: allTargets.flatMap { [$0.0, $0.1].compactMap { $0 } } + [widgetTarget],
            schemes: schemes
        )
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(
        module: ModuleDependency,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets
    ) -> (Target, Target?) {
        let name = module.name
        let directory = "Modules/\(module.category.directoryName)"
        let resources: [String] =
            (module.category.hasResources ? ["\(directory)/\(name)/Resources/**"] : [])
            + module
            .additionalResources
        let sources = Target.target(
            name: name,
            destinations: destinations,
            product: module.productType ?? productType(),
            bundleId: "\(domain).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["\(directory)/\(name)/Sources/**"],
            resources: .resources(resources.map { .init(stringLiteral: $0) }),
            dependencies: module.dependencies,
            settings: makeSettings()
        )
        if case .featureInterface = module.category {
            return (sources, nil)
        }
        let tests = Target.target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(domain).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["\(directory)/\(name)/Tests/**"],
            resources: [],
            dependencies: [.target(name: name)],
            settings: makeSettings()
        )
        return (sources, tests)
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(
        name: String,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets,
        dependencies: [TargetDependency]
    ) -> (Target, Target) {
        let mainTarget = Target.target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: InfoPlist.infoPlistForApp()),
            sources: ["\(name)/Sources/**"],
            resources: ["\(name)/Resources/**", "OpenAPI/**"],
            entitlements: "Supporting Files/SNUTT.entitlements",
            dependencies: dependencies,
            settings: makeSettings()
        )

        let testTarget = Target.target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(domain).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ],
            settings: makeSettings()
        )
        return (mainTarget, testTarget)
    }

    /// Helper function to create the widget extension.
    private static func makeWidgetTarget(
        name: String,
        deploymentTargets: DeploymentTargets,
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: "\(name)WidgetExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER).widget",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleShortVersionString": marketingVersion,
                    "CFBundleVersion": buildNumber,
                    "NSExtension": ["NSExtensionPointIdentifier": "com.apple.widgetkit-extension"],
                ]
            ),
            sources: ["SNUTTWidget/Sources/**"],
            resources: ["SNUTTWidget/Resources/**"],
            entitlements: "Supporting Files/SNUTT.entitlements",
            dependencies: dependencies,
            settings: makeSettings()
        )
    }

    private static func productType() -> Product {
        if case let .string(productType) = Environment.productType {
            productType == "static-library" ? .staticLibrary : .framework
        } else {
            .framework
        }
    }

    private static func makeSettings() -> Settings {
        .settings(
            base: ["OTHER_LDFLAGS": "-ObjC"]
                .swiftVersion("6.1")
                .merging(["SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY": SettingValue(true)])
                .merging(["_EXPERIMENTAL_SWIFT_EXPLICIT_MODULES": SettingValue(true)]),

            configurations: [
                .debug(
                    name: .dev,
                    settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG"],
                    xcconfig: "XCConfigs/Dev.xcconfig"
                ),
                .release(name: .prod, xcconfig: "XCConfigs/Prod.xcconfig"),
            ]
        )
    }

    private static func makeSchemes(name: String) -> [Scheme] {
        return [
            .scheme(
                name: "\(name) Dev",
                shared: true,
                buildAction: .buildAction(targets: [.target(name)]),
                runAction: .runAction(configuration: .dev, executable: .target(name)),
                archiveAction: .archiveAction(configuration: .dev),
                profileAction: .profileAction(configuration: .prod, executable: .target(name)),
                analyzeAction: .analyzeAction(configuration: .dev)
            ),
            .scheme(
                name: "\(name) Prod",
                shared: true,
                buildAction: .buildAction(targets: [.target(name)]),
                runAction: .runAction(configuration: .prod, executable: .target(name)),
                archiveAction: .archiveAction(configuration: .prod),
                profileAction: .profileAction(configuration: .prod, executable: .target(name)),
                analyzeAction: .analyzeAction(configuration: .prod)
            ),
            .scheme(
                name: "\(name) Widget",
                shared: true,
                buildAction: .buildAction(targets: [.target(name), .target("\(name)WidgetExtension")]),
                runAction: .runAction(configuration: .dev, executable: nil),
                archiveAction: .archiveAction(configuration: .dev),
                profileAction: nil,
                analyzeAction: nil
            ),
        ]
    }

    private static func makeModuleTestsScheme(testTargets: [Target]) -> Scheme {
        let testableTargets: [TestableTarget] = testTargets.map { .testableTarget(target: .target($0.name)) }
        return .scheme(
            name: "ModuleTests",
            shared: true,
            buildAction: .buildAction(targets: testTargets.map { .target($0.name) }),
            testAction: .targets(testableTargets, configuration: .dev)
        )
    }

    private static func makePreviewSchemes(moduleDependencies: [ModuleDependency]) -> [Scheme] {
        let previewableModules = moduleDependencies.filter { module in
            guard module.previewable else { return false }

            switch module.category {
            case .feature:
                return true
            case .shared(ui: let isUI):
                return isUI
            default:
                return false
            }
        }

        return previewableModules.map { module in
            .scheme(
                name: "\(module.name) Preview",
                shared: true,
                buildAction: .buildAction(targets: [.target(module.name)]),
                runAction: .runAction(configuration: .dev),
                archiveAction: nil,
                profileAction: nil,
                analyzeAction: nil
            )
        }
    }
}

extension ProjectDescription.ConfigurationName {
    public static let dev: Self = .configuration("Dev")
    public static let prod: Self = .configuration("Prod")
}
