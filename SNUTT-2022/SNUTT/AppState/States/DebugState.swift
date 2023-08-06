//
//  DebugState.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

@preconcurrency import Combine

#if DEBUG
    @MainActor
    class DebugState {
        let networkLogStore = NetworkLogStore()

        var currentLogs: AnyPublisher<[NetworkLogEntry], Never> {
            networkLogStore.$logs.eraseToAnyPublisher()
        }
    }
#endif
