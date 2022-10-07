//
//  LicenseView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct LicenseView: View {
    enum LicenseApps: CaseIterable {
        case alamofire
        case facebookSDK

        var projectName: String {
            switch self {
            case .alamofire:
                return "Alamofire"
            case .facebookSDK:
                return "Facebook iOS SDK"
            }
        }

        var copyright: String {
            switch self {
            case .alamofire:
                return "Copyright (c) 2014-2022 Alamofire Software Foundation"
            case .facebookSDK:
                return "Copyright (c) Meta Platforms, Inc."
            }
        }

        var homepage: String {
            switch self {
            case .alamofire:
                return "https://github.com/Alamofire/Alamofire"
            case .facebookSDK:
                return "https://github.com/facebook/facebook-ios-sdk"
            }
        }

        var license: String {
            switch self {
            case .alamofire:
                return "MIT License"
            case .facebookSDK:
                return ""
            }
        }
    }

    var body: some View {
        List {
            ForEach(LicenseApps.allCases, id: \.self) { project in
                VStack(alignment: .leading) {
                    Text(project.projectName)
                        .font(.system(size: 17, weight: .semibold))
                    Text(project.homepage)
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .padding(.bottom, 5)

                    Text(project.copyright)
                        .font(.system(size: 14))
                    Text(project.license)
                        .font(.system(size: 14))
                }
            }
        }
        .navigationTitle("라이선스 고지")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicenseScene_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView()
    }
}
