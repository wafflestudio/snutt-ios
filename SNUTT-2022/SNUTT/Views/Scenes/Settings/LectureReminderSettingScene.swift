//
//  LectureReminderSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 7/3/25.
//

import SwiftUI

struct LectureReminderSettingScene: View {
    var body: some View {
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
        .navigationTitle("강의 리마인더")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        LectureReminderSettingScene()
    }
}
