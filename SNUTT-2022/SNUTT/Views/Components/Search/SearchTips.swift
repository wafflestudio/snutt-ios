//
//  SearchTips.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/04.
//

import SwiftUI

struct SearchTips: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
            
            Text("SNUTT 검색 꿀팁 🍯")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)
            
            Spacer()
                .frame(height: 5)
            
            VStack(spacing: 5) {
                Text("다양한 조합으로 검색해보세요.")
                    .font(.system(size: 16, weight: .semibold))
                Text("ex) 2학년 컴공 전필 / 경영 영강")
                    .font(.system(size: 16))
            }
            
            Spacer()
                .frame(height: 5)
            
            VStack(spacing: 5) {
                Text("줄임말로 검색해보세요.")
                    .font(.system(size: 16, weight: .semibold))
                Text("ex) 죽음의 과학적 이해 유성호 → 죽과이 유성호")
                    .font(.system(size: 16))
            }
            
            Spacer()
            Spacer()
            
        }
        .foregroundColor(STColor.whiteTranslucent)
    }
}

struct SearchTips_Previews: PreviewProvider {
    static var previews: some View {
        SearchTips()
    }
}
