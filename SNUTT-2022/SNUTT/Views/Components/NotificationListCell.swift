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
        HStack(alignment: .top, spacing: 10) {
            Image(notification.imageName)
                .resizable()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 14, weight: .bold))

                    Spacer()

                    Text(notification.dateString)
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }

                Text(notification.message)
                    .font(.system(size: 14, weight: .regular))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NotificationListCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NotificationListCell(notification: .init(message: "공지", created_at: "2022-04-30T08:11:04.200Z", type: .normal, user_id: ""))
            NotificationListCell(notification: .init(message: "알림", created_at: "2022-04-30T08:11:04.200Z", type: .link, user_id: ""))
            NotificationListCell(notification: .init(message: "아무내용", created_at: "2022-04-30T08:11:04.200Z", type: .lectureUpdate, user_id: ""))
            NotificationListCell(notification: .init(message: String(repeating: "공지입니다. ", count: 10), created_at: "2022-04-30T08:11:04.200Z", type: .lectureRemove, user_id: ""))
            NotificationListCell(notification: .init(message: String(repeating: "공지입니다. ", count: 30), created_at: "2022-04-30T08:11:04.200Z", type: .courseBook, user_id: ""))
        }
    }
}
