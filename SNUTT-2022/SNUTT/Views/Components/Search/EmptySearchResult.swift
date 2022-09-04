//
//  EmptySearchResult.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/04.
//

import SwiftUI

struct EmptySearchResult: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 80))
            
            Text("검색 결과가 존재하지 않습니다")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)
            
            Text("다른 검색어로 다시 시도해주세요.")
                .font(.system(size: 16))
            
            Spacer()
            Spacer()
            
        }
        .foregroundColor(STColor.whiteTranslucent)
    }
}

struct EmptySearchResult_Previews: PreviewProvider {
    static var previews: some View {
        EmptySearchResult()
    }
}
