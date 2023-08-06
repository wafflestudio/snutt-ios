//
//  EmptyLectureList.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/26.
//

import SwiftUI

struct EmptyLectureList: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("logo")
                .resizable()
                .frame(width: 20, height: 20)

            Spacer().frame(height: 16)

            Text("시간표에 강좌가 없습니다.")
                .font(STFont.subtitle)

            Spacer().frame(height: 6)

            Text("강좌를 찾아서 넣을 수도 있지만, 우측 상단의 + 버튼을 눌러 직접 만들 수도 있습니다.")
                .font(STFont.detailLabel)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .foregroundColor(Color.primary.opacity(0.4))
    }
}

#if DEBUG
    struct LectureListEmptyView_Previews: PreviewProvider {
        static var previews: some View {
            EmptyLectureList()
        }
    }
#endif
