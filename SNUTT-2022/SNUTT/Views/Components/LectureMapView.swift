//
//  LectureMapView.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/26.
//

import SwiftUI

struct LectureMapView: View {
    @Binding var draw: Bool
    @State private var isMapNotInstalledAlertPresented: Bool = false
    let buildings: [Location: String]
    
    var body: some View {
        ZStack {
            KakaoMapView(draw: $draw,
                         isMapNotInstalledAlertPresented: $isMapNotInstalledAlertPresented,
                         buildings: buildings)
                .onAppear {
                    self.draw = true
                }.onDisappear {
                    self.draw = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("실행 가능한 지도 어플리케이션이 없습니다.", isPresented: $isMapNotInstalledAlertPresented, actions: {})
    }
}
