//
//  VacancyBanner.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/28.
//

import SwiftUI

struct VacancyBanner: View {
    let action: () -> Void
    let close: () -> Void

    var body: some View {
        HStack(spacing: 0) {
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
            }

            Spacer()

            Button {
                close()
            } label: {
                Image("xmark.white")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
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
        VacancyBanner {} close: {}
    }
}
