import ProjectDescription

let domain = "com.wafflestudio"

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
        let mainTargetDependencies: [TargetDependency] = moduleDependencies.map { .target(name: $0.name) } + externalDependencies
        let widgetTarget = makeWidgetTarget(name: name, deploymentTargets: deploymentTargets, dependencies: widgetDependencies)
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
        let schemes = makeSchemes(name: name) + [makeModuleTestsScheme(testTargets: testTargets)]
        return Project(name: name,
                       organizationName: "wafflestudio.com",
                       options: .options(automaticSchemesOptions: .disabled),
                       packages: swiftPackages,
                       settings: makeSettings(),
                       targets: allTargets.flatMap { [$0.0, $0.1].compactMap({ $0 }) } + [widgetTarget],
                       schemes: schemes)
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
        let resources: [String] = (module.category.hasResources ? ["\(directory)/\(name)/Resources/**"] : []) + module.additionalResources
        let sources = Target.target(name: name,
                                    destinations: destinations,
                                    product: module.productType ?? productType(),
                                    bundleId: "\(domain).\(name)",
                                    deploymentTargets: deploymentTargets,
                                    infoPlist: .default,
                                    sources: ["\(directory)/\(name)/Sources/**"],
                                    resources: .resources(resources.map { .init(stringLiteral: $0) }),
                                    dependencies: module.dependencies,
                                    settings: makeSettings())
        if case .featureInterface = module.category {
            return (sources, nil)
        }
        let tests = Target.target(name: "\(name)Tests",
                                  destinations: destinations,
                                  product: .unitTests,
                                  bundleId: "\(domain).\(name)Tests",
                                  deploymentTargets: deploymentTargets,
                                  infoPlist: .default,
                                  sources: ["\(directory)/\(name)/Tests/**"],
                                  resources: [],
                                  dependencies: [.target(name: name)],
                                  settings: makeSettings())
        return (sources, tests)
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(
        name: String,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets,
        dependencies: [TargetDependency]
    ) -> (Target, Target) {
        let infoPlist: [String: Plist.Value] = [
            "CFBundleVersion": "1.0.0",
            "UILaunchStoryboardName": "LaunchScreen",
            "API_SERVER_URL": "$(API_SERVER_URL)",
            "API_KEY": "$(API_KEY)",
            "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
            "CFBundleURLTypes": [
                [
                    "CFBundleURLSchemes": ["$(URL_SCHEME)"],
                    "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                ]
            ]
        ]

        let mainTarget = Target.target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
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
                .target(name: "\(name)"),
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
            infoPlist: .extendingDefault(with: ["NSExtension": ["NSExtensionPointIdentifier": "com.apple.widgetkit-extension"]]),
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
            base: [:]
                .swiftVersion("6.0")
                .merging(["SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY": SettingValue(true)])
                .merging(["_EXPERIMENTAL_SWIFT_EXPLICIT_MODULES": SettingValue(true)]),

            configurations: [
                .debug(name: .dev, settings: ["OTHER_SWIFT_FLAGS": "-DDEBUG"], xcconfig: "XCConfigs/Dev.xcconfig"),
                .release(name: .prod, xcconfig: "XCConfigs/Prod.xcconfig"),
            ]
        )
    }

    private static func makeSchemes(name: String) -> [Scheme] {
        return [
            .scheme(
                name: "\(name) Dev",
                shared: true,
                buildAction: .buildAction(targets: [.target(name)], preActions: [
                    .executionAction(scriptText: updateOpenAPISpecSymlinkPreActionScript(configuration: .dev), target: .target(name)),
                ]),
                runAction: .runAction(configuration: .dev, executable: .target(name)),
                archiveAction: .archiveAction(configuration: .dev),
                profileAction: .profileAction(configuration: .prod, executable: .target(name)),
                analyzeAction: .analyzeAction(configuration: .dev)
            ),
            .scheme(
                name: "\(name) Prod",
                shared: true,
                buildAction: .buildAction(targets: [.target(name)], preActions: [
                    .executionAction(scriptText: updateOpenAPISpecSymlinkPreActionScript(configuration: .dev), target: .target(name)), // TODO: change to .prod
                ]),
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

    private static func updateOpenAPISpecSymlinkPreActionScript(configuration: ProjectDescription.ConfigurationName) -> String {
        let apiUrl = if configuration == .dev {
            "https://snutt-api-dev.wafflestudio.com/v3/api-docs"
        } else {
            "https://snutt-api-dev.wafflestudio.com/v3/api-docs" // TODO: Fix
        }
        return """
        # Disabled temporarily
        exit 0
        
        OPENAPI_DIR="$PROJECT_DIR/OpenAPI"
        OPENAPI_FILE="$OPENAPI_DIR/openapi-\(configuration == .dev ? "dev" : "prod").json"
        API_URL=\(apiUrl)

        # Download the openapi.json file from the server endpoint
        curl -o "$OPENAPI_FILE" "$API_URL"
            
        # Replace unparsable status code strings with valid status codes
        sed -i '' 's/"400 (1)"/"400"/g; s/"400 (2)"/"402"/g' "$OPENAPI_FILE"

        # Create a symlink to the downloaded openapi.json file
        ln -sf "$OPENAPI_FILE" "$OPENAPI_DIR/openapi.json"

        # Output the symlink target path
        readlink -f "$OPENAPI_DIR/openapi.json"
        """
    }
}

extension ProjectDescription.ConfigurationName {
    public static let dev: Self = .configuration("Dev")
    public static let prod: Self = .configuration("Prod")
}
