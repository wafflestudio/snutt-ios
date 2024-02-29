//
//  TimeRangeSelectionSheet.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/09.
//

import SwiftUI

struct TimeRangeSelectionSheet: View {
    let currentTimetable: Timetable
    let config = TimetableConfiguration().withTimeRangeSelectionMode()

    @Binding var selectedTimeRange: [SearchTimeMaskDto]

    @State private var selectedBlockMask: TimetablePainter.BlockMask
    @State private var temporaryBlockMask: TimetablePainter.BlockMask = Array(repeating: false, count: TimetablePainter.blockMaskSize)

    @State private var selectMode: Bool = true

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    init(currentTimetable: Timetable, selectedTimeRange: Binding<[SearchTimeMaskDto]>) {
        self.currentTimetable = currentTimetable
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(STColor.systemBackground)
        appearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        _selectedTimeRange = selectedTimeRange
        _selectedBlockMask = State(initialValue: TimetablePainter.toBlockMask(from: selectedTimeRange.wrappedValue))
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 10)

                Group {
                    HStack(spacing: 8) {
                        Button {
                            selectedBlockMask = TimetablePainter.toBlockMask(from: currentTimetable.timeMask.filter { $0.day < 5 })
                        } label: {
                            HStack(spacing: 0) {
                                Image("timerange.magicwand")
                                Text("빈시간대 선택하기")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? STColor.gray20 : .white)
                            }
                            .padding(.leading, 6)
                            .padding(.trailing, 8)
                        }
                        .background(Rectangle()
                            .frame(height: 24)
                            .cornerRadius(6)
                            .foregroundColor(colorScheme == .dark ? STColor.darkerGray : STColor.gray2)
                        )

                        Button {
                            resetTemporary()
                            resetSelected()
                        } label: {
                            HStack(spacing: 0) {
                                Image("timerange.reset")
                                Text("초기화")
                                    .font(.system(size: 14))
                                    .foregroundColor(colorScheme == .dark ? STColor.gray30 : STColor.gray20)
                            }
                        }
                        .buttonStyle(DefaultButtonStyle())
                    }

                    Spacer().frame(height: 16)

                    Text("드래그하여 시간대를 선택해보세요.")
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? STColor.darkGray : STColor.gray20)
                }
                .padding(.horizontal, 10)

                Spacer().frame(height: 10)

                GeometryReader { reader in
                    ZStack(alignment: .topLeading) {
                        TimetableGridLayer(current: currentTimetable, config: config)
                        GrayScaledTimetableBlocksLayer
                        selectedTimeRangeBlocksLayer(in: reader.size)
                        temporaryTimeRangeBlocksLayer(in: reader.size)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let start = gesture.startLocation
                                let current = gesture.location
                                if outOfBounds(point: start, in: reader.size) || outOfBounds(point: current, in: reader.size){
                                    return
                                }

                                let currentBlockMask = TimetablePainter.toggleOnBlockMask(at: gesture.location, in: reader.size)
                                temporaryBlockMask = temporaryBlockMask.enumerated().map {
                                    $0.element || currentBlockMask[$0.offset]
                                }
                            }
                            .onEnded { gesture in
                                let start = gesture.startLocation
                                let end = gesture.location
                                if outOfBounds(point: start, in: reader.size) || outOfBounds(point: end, in: reader.size) {
                                    return
                                }

                                selectMode = !TimetablePainter.isSelected(point: start, blockMask: selectedBlockMask, in: reader.size)
                                if selectMode {
                                    selectedBlockMask = selectedBlockMask.enumerated().map {
                                        $0.element || temporaryBlockMask[$0.offset]
                                    }
                                } else {
                                    selectedBlockMask = selectedBlockMask.enumerated().map {
                                        $0.element && !temporaryBlockMask[$0.offset]
                                    }
                                }
                                resetTemporary()
                            }
                    )
                }
            }
            .padding(.horizontal, 20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        selectedTimeRange = TimetablePainter.getSelectedTimeRange(from: selectedBlockMask)
                        dismiss()
                    } label: {
                        Text("완료")
                    }
                }
            }
            .background(STColor.systemBackground)
        }
        .foregroundColor(.primary)
        .interactiveDismissDisabled()
        .ignoresSafeArea(.keyboard)
    }

    private var GrayScaledTimetableBlocksLayer: some View {
        ForEach(currentTimetable.lectures) { lecture in
            LectureBlocks(current: currentTimetable, lecture: lecture.withOccupiedColor(colorScheme: colorScheme), theme: nil, config: config)
                .environment(\.dependencyContainer, nil)
        }
    }

    @ViewBuilder private func selectedTimeRangeBlocksLayer(in size: CGSize) -> some View {
        let width = TimetablePainter.getWeekWidth(in: size, weekCount: TimetablePainter.weekCount)
        let height = TimetablePainter.getSingleBlockHeight(in: size)
        ForEach(Array(zip(selectedBlockMask.indices, selectedBlockMask)), id: \.0) { index, selected in
            if selected, let offsetPoint = TimetablePainter.getOffset(of: index, in: size) {
                Rectangle()
                    .fill(Color(hex: "#1BD0C8").opacity(0.6))
                    .frame(width: width, height: height, alignment: .top)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
            }
        }
    }

    @ViewBuilder private func temporaryTimeRangeBlocksLayer(in size: CGSize) -> some View {
        let width = TimetablePainter.getWeekWidth(in: size, weekCount: TimetablePainter.weekCount)
        let height = TimetablePainter.getSingleBlockHeight(in: size)
        ForEach(Array(zip(temporaryBlockMask.indices, temporaryBlockMask)), id: \.0) { index, selected in
            if selected, let offsetPoint = TimetablePainter.getOffset(of: index, in: size) {
                Rectangle()
                    .fill(Color(hex: "#1BD0C8").opacity(0.6))
                    .frame(width: width, height: height, alignment: .top)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
            }
        }
    }

    private func resetTemporary() {
        temporaryBlockMask = Array(repeating: false, count: TimetablePainter.blockMaskSize)
    }

    private func resetSelected() {
        selectedBlockMask = Array(repeating: false, count: TimetablePainter.blockMaskSize)
    }

    private func outOfBounds(point: CGPoint, in containerSize: CGSize) -> Bool {
        point.x <= TimetablePainter.hourWidth || point.x >= containerSize.width
            || point.y <= TimetablePainter.weekdayHeight || point.y >= containerSize.height
    }
}
