//
//  TimetableGrid.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/09.
//

import SwiftUI


struct TimetableGrid: View {
    
    let viewModel: TimetableViewModel
    
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
        let weekWidth = viewModel.getWeekWidth(in: containerSize)
        return Path { path in
            for i in 0..<viewModel.weekCount {
                let x = viewModel.hourWidth + CGFloat(i) * weekWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: containerSize.height))
            }
        }
    }
    
    /// 한 시간 간격의 수평선
    func horizontalHourlyPaths(in containerSize: CGSize) -> Path {
        let hourHeight = viewModel.getHourHeight(in: containerSize)
        return Path { path in
            for i in 0..<viewModel.hourCount {
                let y = viewModel.weekHeight + CGFloat(i) * hourHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }
    
    /// 30분 간격의 수평선
    func horizontalHalfHourlyPaths(in containerSize: CGSize) -> Path {
        let hourHeight = viewModel.getHourHeight(in: containerSize)
        return Path { path in
            for i in 0..<viewModel.hourCount {
                let y = viewModel.weekHeight + CGFloat(i) * hourHeight + hourHeight / 2
                path.move(to: CGPoint(x: 0 + viewModel.hourWidth, y: y))
                path.addLine(to: CGPoint(x: containerSize.width, y: y))
            }
        }
    }
    
    // MARK: Week and Time Texts
    
    /// 시간표 맨 위쪽, 날짜를 나타내는 행
    var weeksHStack: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.visibleWeeks) { week in
                Text(week.shortSymbol)
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .frame(height: viewModel.weekHeight)
            }
        }
        .padding(.leading, viewModel.hourWidth)
    }
    
    /// 시간표 맨 왼쪽, 시간들을 나타내는 행
    var hoursVStack: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.minHour...viewModel.maxHour, id: \.self) { hour in
                Text(String(hour))
                    .font(STFont.details)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
                    .frame(width: viewModel.hourWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.top, viewModel.weekHeight)
    }
}


struct TimetableGrid_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGrid(viewModel: TimetableViewModel())
    }
}
