//
//  NotificationListCell.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import SwiftUI

struct NotificationListCell: View {
    let notification: STNotification

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Image(notification.imageName)
                    .resizable()
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(notification.title)
                            .font(.system(size: 14, weight: .semibold))

                        Spacer()

                        Text(notification.dateString)
                            .font(.system(size: 14))
                            .foregroundColor(STColor.gray30)
                    }

                    Spacer().frame(height: 6)

                    Text(notification.message)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 7)
                .padding(.trailing, 2)
            }
            .padding(.vertical, 8)

            Rectangle()
                .foregroundColor(STColor.divider)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NotificationListCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NotificationListCell(notification: .init(title: "공지", message: "공지 예시입니다", created_at: "2022-04-30T08:11:04.200Z", type: .normal, user_id: ""))
            NotificationListCell(notification: .init(title: "새로운 알림", message: "알림 예시입니다", created_at: "2022-04-30T08:11:04.200Z", type: .lectureVacancy, user_id: ""))
            NotificationListCell(notification: .init(title: "친구 요청", message: "SNUTT#1234님이 친구 요청을 보냈습니다", created_at: "2022-04-30T08:11:04.200Z", type: .friend, user_id: ""))
            NotificationListCell(notification: .init(title: "폐강 알림", message: String(repeating: "공지입니다. ", count: 10), created_at: "2022-04-30T08:11:04.200Z", type: .lectureRemove, user_id: ""))
            NotificationListCell(notification: .init(title: "2099년 2학기 수강편람이 공개되었습니다.", message: String(repeating: "공지입니다. ", count: 30), created_at: "2022-04-30T08:11:04.200Z", type: .courseBook, user_id: ""))
        }
    }
}
