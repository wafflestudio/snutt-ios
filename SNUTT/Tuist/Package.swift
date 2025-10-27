// swift-tools-version: 5.10
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "Dependencies": .framework,
            "Clocks": .framework,
            "ConcurrencyExtras": .framework,
            "CombineSchedulers": .framework,
            "XCTestDynamicOverlay": .framework,
            "SwiftUIIntrospect": .framework,
            "Spyable": .framework,
            "MemberwiseInit": .framework,
            "DependenciesAdditions": .framework,
            "DependenciesAdditionsBasics": .framework,
            "UserDefaultsDependency": .framework,
            "IssueReporting": .framework,
            "OpenAPIRuntime": .framework,
            "OpenAPIURLSession": .framework,
            "HTTPTypes": .framework,
            "SnapKit": .framework,
            "KakaoSDKCommon": .framework,
            "Alamofire": .framework,
            "DequeModule": .framework,
        ],
        baseSettings: .settings(configurations: [
            .debug(name: .dev),
            .release(name: .prod),
        ])
    )
#endif

let package = Package(
    name: "SNUTT",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Matejkob/swift-spyable", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.5.2"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", branch: "xcode26"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "11.9.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMajor(from: "18.0.1")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.25.0")),
    ]
)
