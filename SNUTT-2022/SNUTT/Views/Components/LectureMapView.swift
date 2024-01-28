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
    let locations: [Location]
    let label: String
    
    var body: some View {
        KakaoMapView(draw: $draw,
                     isMapNotInstalledAlertPresented: $isMapNotInstalledAlertPresented,
                     locations: locations,
                     label: label)
            .onAppear {
                self.draw = true
            }.onDisappear {
                self.draw = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert("연결할 수 있는 지도가 없습니다.", isPresented: $isMapNotInstalledAlertPresented, actions: {})
    }
}
