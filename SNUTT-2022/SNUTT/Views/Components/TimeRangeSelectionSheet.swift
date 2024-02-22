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
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(currentTimetable: Timetable) {
        self.currentTimetable = currentTimetable
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(STColor.systemBackground)
        appearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 10)
                
                Group {
                    HStack(spacing: 8) {
                        Button {
                            // 빈시간대 선택
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
                            // reset
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
                
                ZStack {
                    TimetableGridLayer(current: currentTimetable, config: config)
                    GrayScaledTimetableBlocksLayer
                }
                .gesture(
                    DragGesture()
                        .onEnded { amount in
                            print(amount)
                        }
                )
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
                        // save
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
}
