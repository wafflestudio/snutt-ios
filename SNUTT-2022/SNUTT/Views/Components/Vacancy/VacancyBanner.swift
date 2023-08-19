//
//  VacancyBanner.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/28.
//

import SwiftUI

struct VacancyBanner: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Image("search.vacancy")
                .resizable()
                .frame(width: 19, height: 19)

            Spacer()
                .frame(width: 5)

            Group {
                Text("여기를 눌러 빈자리 알림 서비스를 이용해보세요!")
                    .font(.system(size: 13, weight: .medium))

                Text("NEW")
                    .font(.system(size: 7, weight: .semibold))
                    .baselineOffset(6)
                    .padding(.leading, 2)
            }
            .foregroundColor(.white)

            Spacer()
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(STColor.secondaryCyan)
        .onTapGesture {
            action()
        }
    }
}

struct VacancyBanner_Previews: PreviewProvider {
    static var previews: some View {
        VacancyBanner {}
    }
}
