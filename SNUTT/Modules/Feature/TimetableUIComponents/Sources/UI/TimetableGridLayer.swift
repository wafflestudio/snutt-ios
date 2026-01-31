//
//  TimetableGridLayer.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

public struct TimetableGridLayer: View {
    public let painter: TimetablePainter
    let geometry: TimetableGeometry

    public init(painter: TimetablePainter, geometry: TimetableGeometry) {
        self.painter = painter
        self.geometry = geometry
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            weeksHStack
            hoursVStack
            verticalPaths
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHourlyPaths
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
            horizontalHalfHourlyPaths
                .stroke(Color(UIColor.quaternaryLabel.withAlphaComponent(0.05)))
        }
    }

    // MARK: Grid Paths

    /// 하루 간격의 수직선
    var verticalPaths: Path {
        let weekWidth = painter.getWeekWidth(in: geometry.size)
        return Path { path in
            for i in 0..<painter.weekCount {
                let x = painter.hourWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: geometry.extendedContainerSize.height))
            }
        }
    }

    /// 한 시간 간격의 수평선
    var horizontalHourlyPaths: Path {
        let metrics = painter.getDisplayGridMetrics(in: geometry)
        return Path { path in
            for i in 0...metrics.displayHourCount {
                let y = painter.weekdayHeight + CGFloat(i) * metrics.hourHeight
                guard y <= geometry.extendedContainerSize.height else { break }
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
        }
    }

    /// 30분 간격의 수평선
    var horizontalHalfHourlyPaths: Path {
        let metrics = painter.getDisplayGridMetrics(in: geometry)
        return Path { path in
            for i in 0...metrics.displayHourCount {
                let y = painter.weekdayHeight + CGFloat(i) * metrics.hourHeight + metrics.hourHeight / 2
                guard y <= geometry.extendedContainerSize.height else { break }
                path.move(to: CGPoint(x: 0 + painter.hourWidth, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
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
        let metrics = painter.getDisplayGridMetrics(in: geometry)
        return VStack(spacing: 0) {
            ForEach(0..<metrics.displayHourCount, id: \.self) { hour in
                Text(String(minHour + hour))
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: painter.hourWidth, height: metrics.hourHeight, alignment: .top)
            }
        }
        .padding(.top, painter.weekdayHeight)
    }
}
