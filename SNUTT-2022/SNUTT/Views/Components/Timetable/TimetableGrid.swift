//
//  TimetableGrid.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import SwiftUI


struct TimetableGrid: View {
    let timeWidth: CGFloat = 20
    let weekHeight: CGFloat = 25
    let minTime: Int = 6
    let maxTime: Int = 23
    var hourNum: Int {
        maxTime - minTime + 1
    }
    
    let visibleWeeks: [Week] = [.mon, .tue, .wed, .thu, .fri]
    var weekCount: Int {
        visibleWeeks.count
    }
    
    var body: some View {
        GeometryReader { reader in
            weeksView
            timesView
            verticalPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHourlyPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHalfHourlyPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.05)))
            
        }
    }
    
    // MARK: Grid Paths
    
    /// 컨테이너의 사이즈가 주어졌을 때, 하루의 너비를 계산한다.
    func getWeekWidth(in rect: CGSize) -> CGFloat {
        return (rect.width - timeWidth) / CGFloat(weekCount)
    }
    
    /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
    func getTimeHeight(in rect: CGSize) -> CGFloat {
        return (rect.height - weekHeight) / CGFloat(hourNum)
    }
    
    /// 하루 간격의 수직선
    func verticalPaths(in rect: CGSize) -> Path {
        let weekWidth = getWeekWidth(in: rect)
        return Path { path in
            for i in 0..<weekCount {
                let x = timeWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: rect.height))
            }
        }
    }
    
    /// 한 시간 간격의 수평선
    func horizontalHourlyPaths(in rect: CGSize) -> Path {
        let timeHeight = getTimeHeight(in: rect)
        return Path { path in
            for i in 0..<hourNum {
                let y = weekHeight + CGFloat(i) * timeHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: rect.width, y: y))
            }
        }
    }
    
    /// 30분 간격의 수평선
    func horizontalHalfHourlyPaths(in rect: CGSize) -> Path {
        let timeHeight = getTimeHeight(in: rect)
        return Path { path in
            for i in 0..<hourNum {
                let y = weekHeight + CGFloat(i) * timeHeight + timeHeight / 2
                path.move(to: CGPoint(x: 0 + timeWidth, y: y))
                path.addLine(to: CGPoint(x: rect.width, y: y))
            }
        }
    }
    
    // MARK: Week and Time Texts
    
    var weeksView: some View {
        HStack(spacing: 0) {
            ForEach(visibleWeeks) { week in
                Text(week.shortSymbol)
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .frame(height: weekHeight)
            }
        }
        .padding(.leading, timeWidth)
    }
    
    var timesView: some View {
        VStack(spacing: 0) {
            ForEach(minTime...maxTime, id: \.self) { time in
                Text(String(time))
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: timeWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, weekHeight)
    }
}


struct TimetableGrid_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGrid()
    }
}
