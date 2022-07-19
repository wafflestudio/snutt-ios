//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI
import UIKit
import Combine

class TimetableViewModel: BaseViewModel, ObservableObject {
    @Published var showAlert: Bool = false
    @Published var totalCredit: Int = 0
    @Published var timetableTitle: String = ""
    
    private var bag = Set<AnyCancellable>()
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        timetableSetting.$current
            .map { $0?.totalCredit ?? 0 }
            .assign(to: &$totalCredit)
        
        timetableSetting.$current
            .map { $0?.title ?? "" }
            .assign(to: &$timetableTitle)
    }

    private var timetableService: TimetableServiceProtocol {
        services.timetableService
    }

    private var currentTimetable: Timetable? {
        appState.setting.timetableSetting.current
    }

    var timetableSetting: TimetableSetting {
        appState.setting.timetableSetting
    }
    
    func toggleMenuSheet() {
        appState.setting.menuSheetSetting.isOpen.toggle()
    }

    func fetchRecentTimetable() async {
        if currentTimetable != nil {
            return
        }
        do {
            try await timetableService.fetchRecentTimetable()
        } catch {
            DispatchQueue.main.async {
                self.showAlert = true
            }
        }
    }
    
    struct TimetablePainter {
        /// 시간표 맨 왼쪽, 시간들을 나타내는 열의 너비
        static let hourWidth: CGFloat = 20

        /// 시간표 맨 위쪽, 날짜를 나타내는 행의 높이
        static let weekdayHeight: CGFloat = 25

        /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
        static func getWeekWidth(in containerSize: CGSize, weekCount: Int) -> CGFloat {
            return (containerSize.width - hourWidth) / CGFloat(weekCount)
        }

        /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
        static func getHourHeight(in containerSize: CGSize, hourCount: Int) -> CGFloat {
            return (containerSize.height - weekdayHeight) / CGFloat(hourCount)
        }

        /// 주어진 `TimePlace` 블록의 좌표(오프셋)를 구한다.
        ///
        /// 주어진 `TimePlace`를 시간표에 표시할 수 없는 경우(e.g. 시간이나 요일 범위에서 벗어난 경우 등)에는 `nil`을 리턴한다.
        static func getOffset(of timePlace: TimePlace, in containerSize: CGSize, timetableSetting: TimetableSetting) -> CGPoint? {
            if containerSize == .zero {
                return nil
            }
            let hourIndex = timePlace.startTime - Double(timetableSetting.minHour)
            guard let weekdayIndex = timetableSetting.visibleWeeks.firstIndex(of: timePlace.day) else { return nil }
            if hourIndex < 0 {
                return nil
            }

            let x = hourWidth + CGFloat(weekdayIndex) * getWeekWidth(in: containerSize, weekCount: timetableSetting.weekCount)
            let y = weekdayHeight + CGFloat(hourIndex) * getHourHeight(in: containerSize, hourCount: timetableSetting.hourCount)

            return CGPoint(x: x, y: y)
        }

        /// 주어진 `TimePlace`블록의 높이를 구한다.
        static func getHeight(of timePlace: TimePlace, in containerSize: CGSize, hourCount: Int) -> CGFloat {
            return timePlace.len * getHourHeight(in: containerSize, hourCount: hourCount)
        }
    }

}

