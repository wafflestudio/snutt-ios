//
//  LectureReminderSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 7/3/25.
//

import SwiftUI

struct LectureReminderSettingScene: View {
    
    @ObservedObject var viewModel: LectureReminderViewModel
    
    var body: some View {
        Group {
            if true {
                emptyView
            } else {
                VStack(spacing: 16) {
                    Form {
                        Section {
                            // TODO: Picker for each lecture
                            VStack(alignment: .leading, spacing: 8) {
                                Text("컴퓨터 프로그래밍")
                                    .font(.system(size: 16))
                                Picker("컴퓨터 프로그래밍", selection: .constant(0)) {
                                    Text("없음").tag(0)
                                    Text("10분 전").tag(1)
                                    Text("수업 시작 시").tag(2)
                                    Text("10분 후").tag(3)
                                }
                                .pickerStyle(.segmented)
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        } header: {
                            Text("나의 리마인더")
                        } footer: {
                            Group {
                                Text("강의 리마인더를 설정하면 해당 시간에 푸시 알림을 받을 수 있어요. ") +
                                Text("최신 학기의 대표시간표 속 강의들").fontWeight(.semibold) +
                                Text("에 적용 가능해요.")
                            }
                            .font(.system(size: 13))
                            .lineSpacing(4)
                            .padding(.top, 16)
                            .listRowInsets(EdgeInsets())
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("강의 리마인더")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension LectureReminderSettingScene {
    private var emptyView: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("warning.cat.red")
            
            Text("지정된 대표시간표가 없습니다.")
                .font(.system(size: 15, weight: .semibold))
            
            VStack(spacing: 0) {
                Group {
                    Text("강의 리마인더는")
                    Text("이번 학기의 대표시간표 속 강의").font(.system(size: 13, weight: .semibold))+Text("들에 적용 가능해요.")
                    Text("대표시간표를 지정하고 강의 리마인더를 설정해,\n원하는 시간에 푸시 알림을 받아보세요!")
                }
                .lineHeight(with: .systemFont(ofSize: 13), percentage: 145)
            }
            .foregroundStyle(STColor.gray30)
            
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 80)
        .frame(maxWidth: .infinity)
        .background(STColor.groupBackground)
    }
}
