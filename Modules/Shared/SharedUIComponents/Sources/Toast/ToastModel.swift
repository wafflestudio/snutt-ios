import Foundation

public struct Toast: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let message: String
    public let button: ToastButton?

    public init(
        id: UUID = UUID(),
        message: String,
        button: ToastButton? = nil
    ) {
        self.id = id
        self.message = message
        self.button = button
    }

    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

public struct ToastButton: Sendable {
    public let title: String
    let action: @MainActor @Sendable () async throws -> Void

    public init(
        title: String,
        action: @escaping @MainActor @Sendable () async throws -> Void
    ) {
        self.title = title
        self.action = action
    }
}
