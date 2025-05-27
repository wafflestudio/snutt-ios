//
//  PushNotificationSettingScene.swift
//  SNUTT
//
//  Created by 이채민 on 5/10/25.
//

import SwiftUI
import Combine

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
        @Published private var _options: PushNotificationOptions = .default
        private var cancellables = Set<AnyCancellable>()

        var isLectureUpdatePushOn: Bool {
            get { _options.contains(.lectureUpdate) }
            set { updateOption(.lectureUpdate, enabled: newValue) }
        }

        var isVacancyPushOn: Bool {
            get { _options.contains(.vacancy) }
            set { updateOption(.vacancy, enabled: newValue) }
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.push.$options
                .receive(on: DispatchQueue.main)
                .assign(to: \._options, on: self)
                .store(in: &cancellables)
        }
        
        private func updateOption(_ option: PushNotificationOptions, enabled: Bool) {
            if enabled { _options.insert(option) }
            else       { _options.remove(option) }
            Task { await updatePushPreference() }
        }

        func updatePushPreference() async {
            do {
                try await services.pushService.updatePreference(options: _options)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}
