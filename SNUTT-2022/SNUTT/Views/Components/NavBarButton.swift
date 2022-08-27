//
//  NavBarButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/08.
//

import SwiftUI

struct NavBarButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(imageName)
        }
        .frame(width: 30, height: 45)
    }
}

struct NavBarButton_Previews: PreviewProvider {
    static var previews: some View {
        NavBarButton(imageName: "nav.menu") {
            print("button tapped!")
        }
    }
}
