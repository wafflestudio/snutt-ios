import SwiftUI

extension EnvironmentValues {
    @Entry public var presentToast: @MainActor (Toast) -> Void = { _ in }
}

extension View {
    /// Adds toast presentation capability to the view hierarchy.
    /// This modifier should be applied at the root level of your view hierarchy.
    ///
    /// Example:
    /// ```swift
    /// var body: some View {
    ///     ContentView()
    ///         .overlayToast()
    /// }
    /// ```
    ///
    /// Then in any child view:
    /// ```swift
    /// @Environment(\.presentToast) var presentToast
    ///
    /// Button("Show Toast") {
    ///     presentToast(Toast(
    ///         message: "관심강좌가 등록되었습니다.",
    ///         button: ToastButton(title: "보기", action: {
    ///             // Handle action
    ///         })
    ///     ))
    /// }
    /// ```
    public func overlayToast() -> some View {
        ToastContainerModifier(content: self)
    }
}

private struct ToastContainerModifier<Content: View>: View {
    @State private var viewModel = ToastContainerViewModel()
    let content: Content

    init(content: Content) {
        self.content = content
    }

    var body: some View {
        content
            .environment(
                \.presentToast,
                { [viewModel] toast in
                    viewModel.present(toast)
                }
            )
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    ForEach(viewModel.toasts) { toast in
                        ToastItemView(toast: toast) {
                            viewModel.handleButtonTap(for: toast)
                        }
                        .transition(.move(edge: .bottom).combined(with: .blurReplace))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .animation(.defaultSpring, value: viewModel.toasts)
            }
    }
}
