//
//  LectureDetailList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/23.
//

import SwiftUI


struct LectureDetailList: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                LectureDetailListCell(label: "강의명", content: "운영체제")
                LectureDetailListCell(label: "교수", content: "전병곤")
            }
            .padding()
            .background(Color.white)
            
            VStack(spacing: 15) {
                LectureDetailListCell(label: "강의명", content: "운영체제")
                LectureDetailListCell(label: "교수", content: "전병곤")
            }
            .padding()
            .background(Color.white)

        }.background(Color(UIColor.quaternarySystemFill))
        
    }
}

struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        LectureDetailList()
    }
}
