public enum ModuleCategory: Sendable {
    case feature
    case featureInterface
    case shared(ui: Bool = false)
    case utility(ui: Bool = false)

    public var directoryName: String {
        switch self {
        case .feature, .featureInterface:
            "Feature"
        case .shared:
            "Shared"
        case .utility:
            "Utility"
        }
    }

    var hasResources: Bool {
        switch self {
        case .feature:
            true
        case .shared(ui: true), .utility(ui: true):
            true
        default:
            false
        }
    }
}
