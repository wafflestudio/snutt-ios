//
//  TimetableSettingView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableUIComponents

struct TimetableSettingView: View {
    let makePainter: () -> TimetablePainter
    @Binding var config: TimetableConfiguration

    var body: some View {
        Form {
            Section {
                Toggle(
                    SettingsStrings.displayTableAutoFit,
                    isOn: $config.autoFit
                )
                Toggle(
                    SettingsStrings.displayTableNonCompact,
                    isOn: $config.compactMode
                )
            } footer: {
                if config.compactMode {
                    Text(SettingsStrings.displayTableInfoWarning)
                }
            }

            Section {
                Toggle(
                    SettingsStrings.displayTableLectureTitle,
                    isOn: $config.visibilityOptions.isLectureTitleEnabled
                )
                Toggle(
                    SettingsStrings.displayTablePlace,
                    isOn: $config.visibilityOptions.isPlaceEnabled
                )
                Toggle(
                    SettingsStrings.displayTableLectureNumber,
                    isOn: $config.visibilityOptions.isLectureNumberEnabled
                )
                Toggle(
                    SettingsStrings.displayTableInstructor,
                    isOn: $config.visibilityOptions.isInstructorEnabled
                )
            } header: {
                Text(SettingsStrings.displayTableInfo)
            } footer: {
                Text(SettingsStrings.displayTableInfoWarning)
            }

            // TODO: `시간표 범위 설정` 추가

            Section(SettingsStrings.displayTablePreview) {
                TimetableZStack(painter: makePainter())
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(lineWidth: 0.5)
                            .foregroundColor(Color(UIColor.quaternaryLabel))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3)
                    .padding(.vertical, 10)
            }
        }
        .navigationTitle(SettingsStrings.displayTable)
        .navigationBarTitleDisplayMode(.inline)
    }
}
