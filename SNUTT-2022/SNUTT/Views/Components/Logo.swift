//
//  Logo.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct Logo: View {
    let orientation: Orientation
    
    enum Orientation {
        case vertical, horizontal
    }
    
    var body: some View {
        switch orientation {
        case .vertical:
            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                Text("SNUTT")
                    .font(.system(size: 22, weight: .heavy))
            }
        case .horizontal:
            HStack {
                HStack(spacing: 16) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    
                    Text("SNUTT")
                        .font(.system(size: 22, weight: .bold))
                }
            }
        }
    }
}

struct Logo_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Logo(orientation: .horizontal)
            Logo(orientation: .vertical)
        }
    }
}
