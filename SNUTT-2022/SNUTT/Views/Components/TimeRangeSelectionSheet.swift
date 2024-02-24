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
    @State private var selectedBitMask: [Bool] = Array(repeating: false, count: 150)
    
    @State private var temporaryBitMask: [Bool] = Array(repeating: false, count: 150)
    @State private var temporaryTimeRange: [SearchTimeMaskDto] = []

    @State private var timetablePreviewSize: CGSize = .zero
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
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 10)
                
                Group {
                    HStack(spacing: 8) {
                        Button {
                            selectedTimeRange = currentTimetable.timeMask.filter { $0.day < 5 }
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
                            selectedBitMask = Array(repeating: false, count: 150)
                            temporaryBitMask = Array(repeating: false, count: 150)
                            temporaryTimeRange = []
                            selectedTimeRange = []
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
                        SelectedTimeRangeBlocksLayer
                        TemporaryTimeRangeBlocksLayer
                    }
                    .onChange(of: reader.size) { size in
                        timetablePreviewSize = size
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let start = gesture.startLocation
                                
                                if start.x < TimetablePainter.hourWidth || start.y < TimetablePainter.weekdayHeight {
                                    return
                                }

                                let bitMask = TimetablePainter.toggleBitMask(at: gesture.location, in: reader.size)
                                
                                temporaryBitMask = temporaryBitMask.enumerated().map {
                                    $0.element || bitMask[$0.offset]
                                }
                                
                                temporaryTimeRange = TimetablePainter.getSelectedTimeRange(from: temporaryBitMask)
                            }
                            .onEnded { gesture in
                                let start = gesture.startLocation

                                if start.x < TimetablePainter.hourWidth || start.y < TimetablePainter.weekdayHeight {
                                    return
                                }
                                
                                selectMode = !TimetablePainter.isSelected(point: start, bitMask: selectedBitMask, in: reader.size)
                                
                                if selectMode {
                                    selectedBitMask = selectedBitMask.enumerated().map {
                                        return $0.element || temporaryBitMask[$0.offset]
                                    }
                                } else {
                                    selectedBitMask = selectedBitMask.enumerated().map {
                                        return $0.element && !temporaryBitMask[$0.offset]
                                    }
                                }

                                selectedTimeRange = TimetablePainter.getSelectedTimeRange(from: selectedBitMask)
                                temporaryBitMask = Array(repeating: false, count: 150)
                                temporaryTimeRange = []
                            }
                    )
                }
            }
            .padding(.horizontal, 20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        selectedTimeRange = []
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
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
            LectureBlocks(current: currentTimetable, lecture: lecture.withOccupiedColor(colorScheme: colorScheme), theme: .snutt, config: config)
                .environment(\.dependencyContainer, nil)
        }
    }
    
    private var SelectedTimeRangeBlocksLayer: some View {
        ForEach(selectedTimeRange, id: \.self) { time in
            if let offsetPoint = TimetablePainter.getOffset(of: time, in: timetablePreviewSize) {
                Rectangle()
                    .fill(Color(hex: "#1BD0C8").opacity(0.6))
                    .border(Color.black.opacity(0.1), width: 0.5)
                    .frame(width: TimetablePainter.getWeekWidth(in: timetablePreviewSize, weekCount: 5),
                           height: TimetablePainter.getHeight(in: timetablePreviewSize, duration: time.endMinute - time.startMinute),
                           alignment: .top)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
            }
        }
    }
    
    private var TemporaryTimeRangeBlocksLayer: some View {
        ForEach(temporaryTimeRange, id: \.self) { time in
            if let offsetPoint = TimetablePainter.getOffset(of: time, in: timetablePreviewSize) {
                Rectangle()
                    .fill(Color(hex: "#1BD0C8").opacity(0.6))
                    .border(Color.black.opacity(0.1), width: 0.5)
                    .frame(width: TimetablePainter.getWeekWidth(in: timetablePreviewSize, weekCount: 5),
                           height: TimetablePainter.getHeight(in: timetablePreviewSize, duration: time.endMinute - time.startMinute),
                           alignment: .top)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
            }
        }
    }
}
