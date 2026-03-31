import SwiftUI

/// Preference key for communicating safe area insets (including TabView height) from child views
struct SafeAreaBottomInsetsPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    /// Reports the bottom safe area inset (including TabView height) to ancestor views
    func reportBottomSafeArea(_ inset: CGFloat) -> some View {
        preference(key: SafeAreaBottomInsetsPreferenceKey.self, value: inset)
    }
}
