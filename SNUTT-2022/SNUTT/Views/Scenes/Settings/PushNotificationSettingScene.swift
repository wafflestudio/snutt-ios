//
//  PushNotificationSettingScene.swift
//  SNUTT
//
//  Created by 이채민 on 5/10/25.
//

import SwiftUI

struct PushNotificationSettingScene: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        Form {
            Section {
                Group {
                    Toggle("강의 업데이트", isOn: $viewModel.isLectureUpdatePushOn)
                        .animation(.easeInOut, value: viewModel.isLectureUpdatePushOn)
                    Toggle("빈자리 알림", isOn: $viewModel.isVacancyPushOn)
                        .animation(.easeInOut, value: viewModel.isVacancyPushOn)
                }
            }
        }
        .navigationTitle("푸시알림 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension PushNotificationSettingScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private var _isLectureUpdatePushOn: Bool?
        @Published private var _isVacancyPushOn: Bool?

        var isLectureUpdatePushOn: Bool {
            get { _isLectureUpdatePushOn ?? true }
            set {
                _isLectureUpdatePushOn = newValue
                Task { await updatePushPreference() }
            }
        }

        var isVacancyPushOn: Bool {
            get { _isVacancyPushOn ?? true }
            set {
                _isVacancyPushOn = newValue
                Task { await updatePushPreference() }
            }
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.push.$isLectureUpdatePushOn.assign(to: &$_isLectureUpdatePushOn)
            appState.push.$isVacancyPushOn.assign(to: &$_isVacancyPushOn)
        }

        func updatePushPreference() async {
            do {
                try await services.pushService.updatePreference(
                    isLectureUpdatePushOn: isLectureUpdatePushOn,
                    isVacancyPushOn: isVacancyPushOn
                )
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

