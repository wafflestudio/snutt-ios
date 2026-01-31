//
//  TimetableSettingView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI
import ThemesInterface
import TimetableInterface

struct TimetableSettingView: View {
    @Bindable var viewModel: TimetableSettingsViewModel
    @Environment(\.timetableUIProvider) private var timetableUIProvider
    @Environment(\.themeViewModel) private var themeViewModel

    var body: some View {
        Form {
            Section {
                Toggle(
                    SettingsStrings.displayTableAutoFit,
                    isOn: $viewModel.configuration.autoFit
                )
                Toggle(
                    SettingsStrings.displayTableNonCompact,
                    isOn: $viewModel.configuration.compactMode
                )
            } footer: {
                if viewModel.configuration.compactMode {
                    Text(SettingsStrings.displayTableInfoWarning)
                }
            }

            Section {
                Toggle(
                    SettingsStrings.displayTableLectureTitle,
                    isOn: $viewModel.configuration.visibilityOptions.isLectureTitleEnabled
                )
                Toggle(
                    SettingsStrings.displayTablePlace,
                    isOn: $viewModel.configuration.visibilityOptions.isPlaceEnabled
                )
                Toggle(
                    SettingsStrings.displayTableLectureNumber,
                    isOn: $viewModel.configuration.visibilityOptions.isLectureNumberEnabled
                )
                Toggle(
                    SettingsStrings.displayTableInstructor,
                    isOn: $viewModel.configuration.visibilityOptions.isInstructorEnabled
                )
            } header: {
                Text(SettingsStrings.displayTableInfo)
            } footer: {
                Text(SettingsStrings.displayTableInfoWarning)
            }

            if !viewModel.configuration.autoFit {
                Section(SettingsStrings.displayTableRange) {
                    SettingsNavigationLink(
                        title: SettingsStrings.displayTableDaySelection,
                        value: SettingsPathType.timetableRange,
                        detail: viewModel.configuration.visibleWeeks.map { $0.shortSymbol }.joined(separator: " ")
                    )

                    VStack(alignment: .leading) {
                        Text(SettingsStrings.displayTableTimeSlot)

                        TimeRangeSlider(
                            minHour: $viewModel.configuration.minHour,
                            maxHour: $viewModel.configuration.maxHour
                        )
                        .frame(height: 40)
                    }
                }
            }

            if let timetable = viewModel.timetable {
                Section(SettingsStrings.displayTablePreview) {
                    timetableUIProvider.timetableView(
                        timetable: timetable,
                        configuration: viewModel.configuration,
                        preferredTheme: themeViewModel.selectedTheme,
                        availableThemes: themeViewModel.availableThemes
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
        }
        .navigationTitle(SettingsStrings.displayTable)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadInitialTimetable() }
        .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
    }
}

struct TimetableRangeSelectionView: View {
    @Bindable var viewModel: TimetableSettingsViewModel

    var body: some View {
        List {
            ForEach(Weekday.allCases) { weekday in
                Button {
                    viewModel.toggleWeekday(weekday: weekday)
                } label: {
                    HStack {
                        Text(weekday.symbol)
                        Spacer()
                        if viewModel.configuration.visibleWeeks.contains(weekday) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle(SettingsStrings.displayTableDaySelection)
    }
}

#Preview {
    TimetableSettingView(viewModel: .init())
}
