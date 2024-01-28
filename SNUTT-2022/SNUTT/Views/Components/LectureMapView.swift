//
//  LectureMapView.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/26.
//

import SwiftUI

struct LectureMapView: View {
    @Binding var draw: Bool
    let buildings: [Location: String]
    
    @State private var isMapNotInstalledAlertPresented: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            KakaoMapView(draw: $draw,
                         isMapNotInstalledAlertPresented: $isMapNotInstalledAlertPresented,
                         colorScheme: colorScheme,
                         buildings: buildings)
                .onAppear {
                    self.draw = true
                }.onDisappear {
                    self.draw = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Image("map.beta")
        }
        .alert("실행 가능한 지도 어플리케이션이 없습니다.", isPresented: $isMapNotInstalledAlertPresented, actions: {})
    }
}
