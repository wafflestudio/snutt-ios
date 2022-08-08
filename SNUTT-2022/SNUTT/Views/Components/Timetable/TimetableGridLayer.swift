//
//  TimetableGridLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import SwiftUI

struct TimetableGridLayer: View {
    typealias Painter = TimetablePainter
    let current: Timetable?
    let config: TimetableConfiguration

    var body: some View {
        GeometryReader { reader in
            weeksHStack
            hoursVStack
            verticalPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHourlyPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHalfHourlyPaths(in: reader.size)
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(config.isWidget ? 0.02 : 0.05)))
        }

        let _ = debugChanges()
    }

    // MARK: Grid Paths

    /// 하루 간격의 수직선
    func verticalPaths(in containerSize: CGSize) -> Path {
        let weekWidth = Painter.getWeekWidth(in: containerSize, weekCount: config.weekCount)
        return Path { path in
            for i in 0 ..< config.weekCount {
                let x = Painter.hourWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: containerSize.height))
            }
        }
    }

    /// 한 시간 간격의 수평선
    func horizontalHourlyPaths(in containerSize: CGSize) -> Path {
        let hourCount = Painter.getHourCount(current: current, config: config)
        let hourHeight = Painter.getHourHeight(in: containerSize, hourCount: hourCount)
        return Path { path in
            for i in 0 ..< hourCount {
                let y = Painter.weekdayHeight + CGFloat(i) * hourHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }

    /// 30분 간격의 수평선
    func horizontalHalfHourlyPaths(in containerSize: CGSize) -> Path {
        let hourCount = Painter.getHourCount(current: current, config: config)
        let hourHeight = Painter.getHourHeight(in: containerSize, hourCount: hourCount)
        return Path { path in
            for i in 0 ..< hourCount {
                let y = Painter.weekdayHeight + CGFloat(i) * hourHeight + hourHeight / 2
                path.move(to: CGPoint(x: 0 + Painter.hourWidth, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }

    // MARK: Week and Time Texts

    /// 시간표 맨 위쪽, 날짜를 나타내는 행
    var weeksHStack: some View {
        HStack(spacing: 0) {
            ForEach(config.visibleWeeks) { week in
                Text(week.shortSymbol)
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .frame(height: Painter.weekdayHeight)
            }
        }
        .padding(.leading, Painter.hourWidth)
    }

    /// 시간표 맨 왼쪽, 시간들을 나타내는 행
    var hoursVStack: some View {
        let minHour = Painter.getStartingHour(current: current, config: config)
        let maxHour = Painter.getEndingHour(current: current, config: config)
        return VStack(spacing: 0) {
            ForEach(minHour ... maxHour, id: \.self) { hour in
                Text(String(hour))
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: Painter.hourWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, Painter.weekdayHeight)
    }
}

// struct TimetableGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = TimetableViewModel(container: .preview)
//        TimetableGridLayer()
//            .environmentObject(viewModel.timetableState)
//    }
// }
