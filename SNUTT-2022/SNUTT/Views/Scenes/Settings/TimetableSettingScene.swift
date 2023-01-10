//
//  TimetableSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import Combine
import SwiftUI
import UIKit

struct TimetableSettingScene: View {
    @ObservedObject var viewModel: ViewModel
    @State var start: Date = .now
    var body: some View {
        Form {
            Section {
                Toggle("자동 맞춤", isOn: $viewModel.timetableConfig.autoFit)
                    .animation(.easeInOut, value: viewModel.timetableConfig.autoFit)

                Toggle("컴팩트 모드 (Beta)", isOn: $viewModel.timetableConfig.compactMode)
                    .animation(.easeInOut, value: viewModel.timetableConfig.compactMode)
            } footer: {
                if viewModel.timetableConfig.compactMode {
                    Text("꽉 찬 시간표를 표시합니다. 직접 추가한 강의와 일부 겹치는 현상이 발생할 수 있습니다.")
                }
            }

            if !viewModel.timetableConfig.autoFit {
                Section(header: Text("시간표 범위 설정")) {
                    SettingsLinkItem(title: "요일", detail: viewModel.visibleWeekdaysPreview) {
                        List {
                            ForEach(Weekday.allCases) { weekday in
                                Button {
                                    viewModel.toggleWeekday(weekday: weekday)
                                } label: {
                                    HStack {
                                        Text(weekday.symbol)
                                        Spacer()
                                        if viewModel.timetableConfig.visibleWeeks.contains(weekday) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        .navigationBarTitle("요일 선택")
                    }

                    Group {
                        DatePicker("시작",
                                   selection: $viewModel.minHour,
                                   in: viewModel.minTimeRange,
                                   displayedComponents: [.hourAndMinute])
                        DatePicker("종료",
                                   selection: $viewModel.maxHour,
                                   in: viewModel.maxTimeRange,
                                   displayedComponents: [.hourAndMinute])
                    }.datePickerStyle(.compact)
                }
            }

            Section(header: Text("시간표 미리보기")) {
                TimetableZStack(current: viewModel.currentTimetable, config: viewModel.timetableConfig)
                    .animation(.customSpring, value: viewModel.timetableConfig.minHour)
                    .animation(.customSpring, value: viewModel.timetableConfig.maxHour)
                    .animation(.customSpring, value: viewModel.timetableConfig.weekCount)
                    .animation(.customSpring, value: viewModel.timetableConfig.autoFit)
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(lineWidth: 0.5)
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3)
                    .padding(.vertical, 10)
                    .environment(\.dependencyContainer, nil)
            }
        }
        .navigationTitle("시간표 설정")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.minHour, perform: { _ in
            if !viewModel.maxTimeRange.contains(viewModel.maxHour) {
                viewModel.maxHour = viewModel.maxTimeRange.lowerBound
            }
        })
    }
}

extension TimetableSettingScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var currentTimetable: Timetable?
        @Published private var _timetableConfig: TimetableConfiguration = .init()

        var timetableConfig: TimetableConfiguration {
            get { _timetableConfig }
            set { services.timetableService.setTimetableConfig(config: newValue) }
        }

        var minHour: Date {
            get { Calendar.current.date(from: DateComponents(hour: timetableConfig.minHour))! }
            set {
                timetableConfig.minHour = Calendar.current.component(.hour, from: newValue)
            }
        }

        var maxHour: Date {
            get { Calendar.current.date(from: DateComponents(hour: timetableConfig.maxHour))! }
            set {
                timetableConfig.maxHour = Calendar.current.component(.hour, from: newValue)
            }
        }

        var minTimeRange: ClosedRange<Date> {
            let calendar = Calendar.current
            return calendar.date(from: .init(hour: 0, minute: 0))! ... calendar.date(from: .init(hour: 17, minute: 0))!
        }

        var maxTimeRange: ClosedRange<Date> {
            let calendar = Calendar.current
            return calendar.date(byAdding: .hour, value: 6, to: minHour)! ... calendar.date(from: .init(hour: 23, minute: 0))!
        }

        var visibleWeekdaysPreview: String {
            timetableConfig.visibleWeeksSorted
                .map { $0.shortSymbol }.joined(separator: " ")
        }

        override init(container: DIContainer) {
            super.init(container: container)

            appState.timetable.$current.assign(to: &$currentTimetable)
            appState.timetable.$configuration.assign(to: &$_timetableConfig)
        }

        func toggleWeekday(weekday: Weekday) {
            if let removeIndex = timetableConfig.visibleWeeks.firstIndex(of: weekday) {
                timetableConfig.visibleWeeks.remove(at: removeIndex)
            } else {
                timetableConfig.visibleWeeks.append(weekday)
            }
        }
    }
}

#if DEBUG
    struct TimetableSettingScene_Previews: PreviewProvider {
        static var previews: some View {
            TimetableSettingScene(viewModel: .init(container: .preview))
        }
    }
#endif
