//
//  NetworkLogListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

import Alamofire
import Foundation
import SwiftUI

#if DEBUG
    struct NetworkLogListScene: View {
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.logs) { logEntry in
                        NetworkLogEntryView(logEntry: logEntry)
                    }
                }
            }
        }
    }

    extension NetworkLogListScene {
        class ViewModel: BaseViewModel, ObservableObject {
            @Published var logs: [NetworkLogEntry] = []

            override init(container: DIContainer) {
                super.init(container: container)
                appState.debug.currentLogs.assign(to: &$logs)
            }
        }
    }
#endif
