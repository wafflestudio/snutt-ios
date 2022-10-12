//
//  LicenseView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct LicenseView: View {
    var body: some View {
        List {
            ForEach(LicenseApps.allCases, id: \.self) { project in
                VStack(alignment: .leading) {
                    NavigationLink {
                        ScrollView {
                            Text(project.licenseText)
                                .padding()
                        }
                        .navigationTitle(project.projectName)
                    } label: {
                        Text(project.projectName)
                    }
                }
            }
        }
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension LicenseView {
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

        var licenseText: String {
            switch self {
            case .alamofire:
                return """
                Copyright (c) 2014-2022 Alamofire Software Foundation (http://alamofire.org/)

                Permission is hereby granted, free of charge, to any person obtaining a copy
                of this software and associated documentation files (the "Software"), to deal
                in the Software without restriction, including without limitation the rights
                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                copies of the Software, and to permit persons to whom the Software is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in
                all copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                THE SOFTWARE.
                """
            case .facebookSDK:
                return """
                Copyright (c) Meta Platforms, Inc. and affiliates. All rights reserved.

                You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
                copy, modify, and distribute this software in source code or binary form for use
                in connection with the web services and APIs provided by Facebook.

                As with any software that integrates with the Facebook platform, your use of
                this software is subject to the Facebook Platform Policy
                [http://developers.facebook.com/policy/]. This copyright notice shall be
                included in all copies or substantial portions of the software.

                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
                FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
                COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
                IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
                CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                """
            }
        }
    }
}

struct LicenseScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LicenseView()
        }
    }
}
