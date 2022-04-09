//
//  TimetableGrid.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import SwiftUI


struct TimetableGrid: View {

    let hourWidth: CGFloat = 20
    let minHour: Int = 6
    let maxHour: Int = 23
    var hourCount: Int {
        maxHour - minHour + 1
    }
    
    let weekHeight: CGFloat = 25
    let visibleWeeks: [Week] = [.mon, .tue, .wed, .thu, .fri]
    var weekCount: Int {
        visibleWeeks.count
    }
    
    var body: some View {
        GeometryReader { reader in
            weeksHStack
            hoursVStack
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
    func getWeekWidth(in size: CGSize) -> CGFloat {
        return (size.width - hourWidth) / CGFloat(weekCount)
    }
    
    /// 컨테이너의 사이즈가 주어졌을 때, 한 시간의 높이를 계산한다.
    func getHourHeight(in size: CGSize) -> CGFloat {
        return (size.height - weekHeight) / CGFloat(hourCount)
    }
    
    /// 하루 간격의 수직선
    func verticalPaths(in size: CGSize) -> Path {
        let weekWidth = getWeekWidth(in: size)
        return Path { path in
            for i in 0..<weekCount {
                let x = hourWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
        }
    }
    
    /// 한 시간 간격의 수평선
    func horizontalHourlyPaths(in size: CGSize) -> Path {
        let hourHeight = getHourHeight(in: size)
        return Path { path in
            for i in 0..<hourCount {
                let y = weekHeight + CGFloat(i) * hourHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
    }
    
    /// 30분 간격의 수평선
    func horizontalHalfHourlyPaths(in size: CGSize) -> Path {
        let hourHeight = getHourHeight(in: size)
        return Path { path in
            for i in 0..<hourCount {
                let y = weekHeight + CGFloat(i) * hourHeight + hourHeight / 2
                path.move(to: CGPoint(x: 0 + hourWidth, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
    }
    
    // MARK: Week and Time Texts
    
    var weeksHStack: some View {
        HStack(spacing: 0) {
            ForEach(visibleWeeks) { week in
                Text(week.shortSymbol)
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .frame(height: weekHeight)
            }
        }
        .padding(.leading, hourWidth)
    }
    
    var hoursVStack: some View {
        VStack(spacing: 0) {
            ForEach(minHour...maxHour, id: \.self) { hour in
                Text(String(hour))
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: hourWidth)
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
