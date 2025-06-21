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
            "FirebaseCore": .staticLibrary,
            "FirebaseMessaging": .staticLibrary,
            "KakaoMapsSDK-SPM": .staticLibrary,
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
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Matejkob/swift-spyable", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.5.2"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.1.1"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
        .package(url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM.git", .upToNextMajor(from: "2.12.4")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "11.9.0")),
    ]
)
