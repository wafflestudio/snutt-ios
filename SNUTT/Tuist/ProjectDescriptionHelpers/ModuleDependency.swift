import ProjectDescription

public struct ModuleDependency {
    public let name: String
    public let category: ModuleCategory
    public let dependencies: [TargetDependency]
    public let productType: Product?
    public let additionalResources: [String]
    public let infoPlist: [String: Plist.Value]
    public let previewable: Bool

    public static func module(
        name: String,
        category: ModuleCategory,
        previewable: Bool = true,
        productType: Product? = nil,
        dependencies: [TargetDependency] = [],
        additionalResources: [String] = [],
        infoPlist: [String: Plist.Value] = [:],
    ) -> Self {
        .init(
            name: name,
            category: category,
            dependencies: dependencies,
            productType: productType,
            additionalResources: additionalResources,
            infoPlist: infoPlist,
            previewable: previewable
        )
    }
}
