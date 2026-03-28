//
//  TimetableThemePreview.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface
import TimetableInterface

struct TimetableThemePreview: View {
    let timetable: Timetable
    let configuration: TimetableConfiguration
    let theme: Theme

    @Environment(\.timetableUIProvider) private var timetableUIProvider

    var body: some View {
        timetableUIProvider.timetableView(
            timetable: timetable,
            configuration: configuration,
            preferredTheme: theme,
            availableThemes: []
        )
        .frame(height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(UIColor.quaternaryLabel), lineWidth: 0.5)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3)
        )
        .padding(.vertical, 10)
    }
}
