//
//  VacancySugangSnuButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/06.
//

import SwiftUI

struct VacancySugangSnuButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text("수강신청 사이트")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(STColor.cyan)
        }
        .background(STColor.systemBackground)
        .buttonStyle(.plain)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct VacancySugangSnuButton_Previews: PreviewProvider {
    static var previews: some View {
        VacancySugangSnuButton(action: {})
    }
}
