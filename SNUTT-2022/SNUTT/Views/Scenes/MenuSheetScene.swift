//
//  MenuSheetScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/27.
//

import SwiftUI

struct MenuSheetScene: View {
    let viewModel: MenuSheetViewModel
    @ObservedObject var menuSheetSetting: MenuSheetSetting

    init(viewModel: MenuSheetViewModel) {
        self.viewModel = viewModel
        menuSheetSetting = self.viewModel.menuSheetSetting
    }

    var body: some View {
        Sheet(isOpen: $menuSheetSetting.isOpen, orientation: .left(maxWidth: 320), cornerRadius: 0, sheetOpacity: 0.7) {
            VStack {
                HStack {
                    Logo(orientation: .horizontal)
                        .padding(.vertical)
                    Spacer()
                    Button {
                        menuSheetSetting.isOpen.toggle()
                    } label: {
                        Image("xmark.black")
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding([.horizontal, .bottom], 10)
                
                MenuSheetContent(viewModel: .init(container: viewModel.container))
            }
        }
    }
}

///// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    
    let container = DIContainer.preview
    
    
    
    init() {
        container.appState.setting.menuSheetSetting.isOpen = true
    }
    
    var body: some View {
        
        ZStack {
            NavBarButton(imageName: "nav.menu") {
                container.appState.setting.menuSheetSetting.isOpen.toggle()
            }
            MenuSheetScene(viewModel: .init(container: container))
        }
    }
}

struct MenuSheetScene_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetWrapper()
    }
}
