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
    @Binding var focusButton: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        imageName: String,
        focusButton: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self._focusButton = focusButton
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(imageName)
                .rotationEffect(focusButton ? .degrees(45) : .zero)
                .background(
                    focusButton
                    ? Circle().fill(
                        colorScheme == .dark ? STColor.buttonPressed : .white)
                    : nil
                )
        }
        .frame(width: 30, height: 30)
    }
}

struct NavBarButton_Previews: PreviewProvider {
    static var previews: some View {
        NavBarButton(imageName: "nav.menu") {
            print("button tapped!")
        }
    }
}
