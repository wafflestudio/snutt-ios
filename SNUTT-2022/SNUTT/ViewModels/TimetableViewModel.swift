//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import UIKit
import SwiftUI

class TimetableViewModel: ObservableObject {
    @ObservedObject private var state: AppState
    
    var drawing = TimetableDrawing()
    
    var currentTimetable: Timetable {
        state.currentTimetable
    }
    
    var drawingSetting: TimetableSetting {
        state.setting.drawing
    }
    
    func updateTimetable(timeTable: Timetable) {
        state.currentTimetable = timeTable
    }
    
    init(appState: AppState) {
        self.state = appState
    }
    
    struct TimetableDrawing {
        /// 시간표 맨 왼쪽, 시간들을 나타내는 열의 너비
        let hourWidth: CGFloat = 20
        
        /// 시간표 맨 위쪽, 날짜를 나타내는 행의 높이
        let weekdayHeight: CGFloat = 25
        
        /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
        func getWeekWidth(in containerSize: CGSize, weekCount: Int) -> CGFloat {
            return (containerSize.width - hourWidth) / CGFloat(weekCount)
        }
        
        /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
        func getHourHeight(in containerSize: CGSize, hourCount: Int) -> CGFloat {
            return (containerSize.height - weekdayHeight) / CGFloat(hourCount)
        }
        
        /// 주어진 `TimePlace` 블록의 좌표(오프셋)를 구한다.
        ///
        /// 주어진 `TimePlace`를 시간표에 표시할 수 없는 경우(e.g. 시간이나 요일 범위에서 벗어난 경우 등)에는 `nil`을 리턴한다.
        func getOffset(of timePlace: TimePlace, in containerSize: CGSize, drawingSetting: TimetableSetting) -> CGPoint? {
            if containerSize == .zero {
                return nil
            }
            let hourIndex = timePlace.startTime - Double(drawingSetting.minHour)
            guard let weekdayIndex = drawingSetting.visibleWeeks.firstIndex(of: timePlace.day) else { return nil }
            if hourIndex < 0 {
                return nil
            }
            
            let x = hourWidth + CGFloat(weekdayIndex) * getWeekWidth(in: containerSize, weekCount: drawingSetting.weekCount)
            let y = weekdayHeight + CGFloat(hourIndex) * getHourHeight(in: containerSize, hourCount: drawingSetting.hourCount)
            
            return CGPoint(x: x, y: y)
        }
        
        /// 주어진 `TimePlace`블록의 높이를 구한다.
        func getHeight(of timePlace: TimePlace, in containerSize: CGSize, hourCount: Int) -> CGFloat {
            return timePlace.len * getHourHeight(in: containerSize, hourCount: hourCount)
        }
        
        // for test(remove and implement otherwise)
        //    func update() {
        //        appState.system.showActivityIndicator = !appState.system.showActivityIndicator
        //    }
    }
}
