import ProjectDescription

public struct ModuleDependency {
    public let name: String
    public let category: ModuleCategory
    public let dependencies: [TargetDependency]
    public let productType: Product?
    public let additionalResources: [String]

    public static func module(name: String, category: ModuleCategory, productType: Product? = nil, dependencies: [TargetDependency] = [], additionalResources: [String] = []) -> Self {
        .init(name: name, category: category, dependencies: dependencies, productType: productType, additionalResources: additionalResources)
    }
}
