//
//  LectureTimeSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/10.
//

import Combine
import SwiftUI

struct LectureTimeSheetScene: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Sheet(isOpen: $viewModel.isOpen,
              orientation: .bottom(maxHeight: 250),
              disableBackgroundTap: true,
              disableDragGesture: true)
        {
            VStack {
                MenuSheetTopBar(cancel: { viewModel.isOpen = false }, confirm: viewModel.confirm, isSheetOpen: viewModel.isOpen)
                    .padding(.horizontal, 20)

                LectureTimePicker(weekday: $viewModel.weekday, start: $viewModel.start, end: $viewModel.end)

                Spacer()
            }
        }
        .onChange(of: viewModel.isOpen, perform: { _ in
            viewModel.initializeTime()
        })
    }
}

extension LectureTimeSheetScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var weekday: Weekday = .mon
        @Published var start = Calendar.current.date(from: DateComponents(hour: 8))!
        @Published var end = Calendar.current.date(from: DateComponents(hour: 9))!

        @Published private var _isOpen: Bool = false
        var isOpen: Bool {
            get { _isOpen }
            set { services.globalUIService.setIsLectureTimeSheetOpen(newValue, modifying: nil, action: nil) } // close-only
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.menu.$isLectureTimeSheetOpen.assign(to: &$_isOpen)
        }

        private func getSelectedTimePlace() -> TimePlace? {
            guard var initialTimePlace = appState.menu.timePlaceToModify else { return nil }
            initialTimePlace.startTime = TimeUtils.getTime(from: start)
            initialTimePlace.endTime = TimeUtils.getTime(from: end)
            initialTimePlace.day = weekday
            return initialTimePlace
        }

        func initializeTime() {
            guard let initialTimePlace = appState.menu.timePlaceToModify else { return }
            guard let startDate = TimeUtils.getDate(from: initialTimePlace.startTime),
                  let endDate = TimeUtils.getDate(from: initialTimePlace.endTime) else { return }
            start = startDate
            end = endDate
            weekday = initialTimePlace.day
        }

        func confirm() {
            guard let timePlace = getSelectedTimePlace() else { return }
            appState.menu.lectureTimeSheetAction?(timePlace)
            isOpen = false
        }
    }
}

#if DEBUG
    struct LectureTimeSheetScene_Previews: PreviewProvider {
        static var previews: some View {
            let container: DIContainer = .preview
            let _ = container.services.globalUIService.setIsLectureTimeSheetOpen(true, modifying: nil, action: nil)

            LectureTimeSheetScene(viewModel: .init(container: container))
                .background(.blue)
        }
    }
#endif
