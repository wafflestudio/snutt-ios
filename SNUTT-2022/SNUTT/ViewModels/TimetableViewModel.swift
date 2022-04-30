//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import UIKit

class TimetableViewModel {
    /// 시간표 맨 왼쪽, 시간들을 나타내는 열의 너비
    let hourWidth: CGFloat = 20
    
    /// 시간표 맨 위쪽, 날짜를 나타내는 행의 높이
    let weekHeight: CGFloat = 25
    
    // To be deprecated by AppState.settings
    let minHour: Int = 8
    let maxHour: Int = 19
    
    var hourCount: Int {
        maxHour - minHour + 1
    }
    
    let visibleWeeks: [Week] = [.mon, .tue, .wed, .thu, .fri]
    var weekCount: Int {
        visibleWeeks.count
    }
    
    /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
    func getWeekWidth(in containerSize: CGSize) -> CGFloat {
        return (containerSize.width - hourWidth) / CGFloat(weekCount)
    }
    
    /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
    func getHourHeight(in containerSize: CGSize) -> CGFloat {
        return (containerSize.height - weekHeight) / CGFloat(hourCount)
    }
    
    
}
