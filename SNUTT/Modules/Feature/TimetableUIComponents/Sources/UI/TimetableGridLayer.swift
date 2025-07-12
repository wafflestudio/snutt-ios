//
//  TimetableGridLayer.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableGridLayer: View {
    let painter: TimetablePainter

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

    /// 하루 간격의 수직선
    func verticalPaths(in containerSize: CGSize) -> Path {
        let weekCount = painter.weekCount
        let weekWidth = painter.getWeekWidth(in: containerSize, weekCount: weekCount)
        return Path { path in
            for i in 0..<weekCount {
                let x = painter.hourWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: containerSize.height))
            }
        }
    }

    /// 한 시간 간격의 수평선
    func horizontalHourlyPaths(in containerSize: CGSize) -> Path {
        let hourCount = painter.hourCount
        let hourHeight = painter.getHourHeight(in: containerSize, hourCount: hourCount)
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: containerSize.width, y: 0))

            for i in 0...hourCount {
                let y = painter.weekdayHeight + CGFloat(i) * hourHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }

    /// 30분 간격의 수평선
    func horizontalHalfHourlyPaths(in containerSize: CGSize) -> Path {
        let hourCount = painter.hourCount
        let hourHeight = painter.getHourHeight(in: containerSize, hourCount: hourCount)
        return Path { path in
            for i in 0..<hourCount {
                let y = painter.weekdayHeight + CGFloat(i) * hourHeight + hourHeight / 2
                path.move(to: CGPoint(x: 0 + painter.hourWidth, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }

    // MARK: Week and Time Texts

    /// 시간표 맨 위쪽, 날짜를 나타내는 행
    var weeksHStack: some View {
        HStack(spacing: 0) {
            let visibleWeeksSorted = painter.visibleWeeks
            ForEach(visibleWeeksSorted) { week in
                Text(week.shortSymbol)
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .frame(height: painter.weekdayHeight)
            }
        }
        .padding(.leading, painter.hourWidth)
    }

    /// 시간표 맨 왼쪽, 시간들을 나타내는 행
    var hoursVStack: some View {
        let minHour = painter.startingHour
        let maxHour = painter.endingHour
        return VStack(spacing: 0) {
            ForEach(minHour...maxHour, id: \.self) { hour in
                Text(String(hour))
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: painter.hourWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, painter.weekdayHeight)
    }
}

#Preview {
    TimetableGridLayer(painter: makePreviewPainter())
}
