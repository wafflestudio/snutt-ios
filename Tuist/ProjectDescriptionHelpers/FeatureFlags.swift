import ProjectDescription

public enum FeatureFlag: String, Sendable {
    case lectureDiary = "FEATURE_LECTURE_DIARY"
}

public enum CompilationConditions {
    public static func swiftActiveCompilationConditions(
        for configuration: ProjectDescription.ConfigurationName
    ) -> [String] {
        baseConditions(for: configuration) + featureFlags(for: configuration).map(\.rawValue)
    }

    public static func featureFlags(
        for configuration: ProjectDescription.ConfigurationName
    ) -> [FeatureFlag] {
        switch configuration {
        case .dev:
            [.lectureDiary]
        case .prod:
            []
        default:
            []
        }
    }

    private static func baseConditions(
        for configuration: ProjectDescription.ConfigurationName
    ) -> [String] {
        switch configuration {
        case .dev:
            ["DEBUG"]
        case .prod:
            []
        default:
            []
        }
    }
}
