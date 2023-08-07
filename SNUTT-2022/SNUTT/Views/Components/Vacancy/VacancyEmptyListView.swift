//
//  VacancyEmptyListView.swift
//  SNUTT
//
//  Created by user on 2023/08/07.
//

import SwiftUI

struct VacancyEmptyListView: View {
    let detail: () -> Void
    var body: some View {
        VStack(spacing: 15) {
            Image("vacancy.empty")
                .resizable()
                .scaledToFit()
                .frame(width: 260)

            Button {
                detail()
            } label: {
                HStack(spacing: 5) {
                    Image("vacancy.info")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .tint(Color(uiColor: .label).opacity(0.8))
                    Text("자세히 보기")
                        .font(.system(size: 14))
                        .underline()
                        .foregroundColor(Color(uiColor: .label).opacity(0.8))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct VacancyEmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        VacancyEmptyListView {}
    }
}
