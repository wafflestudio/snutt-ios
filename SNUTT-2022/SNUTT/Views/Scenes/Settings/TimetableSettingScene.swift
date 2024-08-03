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
                Group {
                    Toggle("자동 맞춤", isOn: $viewModel.timetableConfig.autoFit)
                    Toggle("꽉 찬 시간표", isOn: $viewModel.timetableConfig.compactMode)
                }
                .animation(.easeInOut, value: viewModel.timetableConfig)
            } footer: {
                if viewModel.timetableConfig.compactMode {
                    Text("꽉 찬 시간표를 표시합니다. 직접 추가한 강의와 일부 겹치는 현상이 발생할 수 있습니다.")
                }
            }

            Section {
                Group {
                    Toggle("강의명", isOn: $viewModel.timetableConfig.visibilityOptions.isLectureTitleEnabled)
                    Toggle("장소", isOn: $viewModel.timetableConfig.visibilityOptions.isPlaceEnabled)
                    Toggle("분반번호", isOn: $viewModel.timetableConfig.visibilityOptions.isLectureNumberEnabled)
                    Toggle("교수", isOn: $viewModel.timetableConfig.visibilityOptions.isInstructorEnabled)
                }
                .animation(.easeInOut, value: viewModel.timetableConfig)
            } header: {
                Text("강의 정보 표시")
            } footer: {
                Text("정보가 많을 경우 일부 텍스트가 표시되지 않을 수 있습니다.")
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

                    VStack(alignment: .leading) {
                        Text("시간대")

                        TimeRangeSlider(minHour: $viewModel.timetableConfig.minHour, maxHour: $viewModel.timetableConfig.maxHour)
                            .frame(height: 40)
                    }
                }
            }

            Section(header: Text("시간표 미리보기")) {
                TimetableZStack(current: viewModel.currentTimetable, config: viewModel.timetableConfig)
                    .animation(.customSpring, value: viewModel.timetableConfig.minHour)
                    .animation(.customSpring, value: viewModel.timetableConfig.maxHour)
                    .animation(.customSpring, value: viewModel.timetableConfig.weekCount)
                    .animation(.customSpring, value: viewModel.timetableConfig.autoFit)
                    .animation(.customSpring, value: viewModel.timetableConfig.visibilityOptions)
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
            let preview = DIContainer.preview
            preview.appState.timetable.configuration.autoFit = false
            return TimetableSettingScene(viewModel: .init(container: preview))
        }
    }
#endif
