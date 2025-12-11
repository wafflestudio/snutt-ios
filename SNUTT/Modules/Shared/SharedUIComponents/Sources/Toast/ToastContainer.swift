import SwiftUI
import SwiftUIUtility

@MainActor
@Observable
final class ToastContainerViewModel {
    private enum Constants {
        static let maxVisibleToasts = 3
    }

    private(set) var toasts: [Toast] = []
    private var dismissTasks: [UUID: Task<Void, Never>] = [:]

    func present(_ toast: Toast) {
        // Dismiss oldest toast if we've reached the maximum
        if toasts.count >= Constants.maxVisibleToasts, let oldestToast = toasts.first {
            dismiss(oldestToast)
        }

        toasts.append(toast)

        let dismissTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(3))
                dismiss(toast)
            } catch {
                // Task was cancelled (e.g., toast manually dismissed)
            }
        }

        dismissTasks[toast.id] = dismissTask
    }

    func handleButtonTap(for toast: Toast) {
        guard let button = toast.button else { return }

        // Cancel auto-dismiss task
        dismissTasks[toast.id]?.cancel()
        dismissTasks.removeValue(forKey: toast.id)

        // Dismiss toast immediately
        dismiss(toast)

        // Execute button action
        Task {
            do {
                try await button.action()
            } catch {
                // Handle error silently or log if needed
            }
        }
    }

    private func dismiss(_ toast: Toast) {
        dismissTasks[toast.id]?.cancel()
        dismissTasks.removeValue(forKey: toast.id)

        withAnimation(.defaultSpring) {
            toasts.removeAll { $0.id == toast.id }
        }
    }
}
