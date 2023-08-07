//
//  NetworkLogListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

#if DEBUG
import Alamofire
import Foundation
import SwiftUI

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
            .toolbar {
                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.medium)
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

            func reset() {
                appState.debug.networkLogStore.reset()
            }
        }
    }
#endif
