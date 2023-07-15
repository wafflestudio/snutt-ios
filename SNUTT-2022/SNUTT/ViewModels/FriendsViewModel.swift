//
//  FriendsViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

#if FEATURE_RN_FRIENDS
import Foundation


class FriendsViewModel: BaseViewModel, ObservableObject {

    override init(container: DIContainer) {
        super.init(container: container)
    }

    var accessToken: String? {
        appState.user.accessToken
    }

}

#endif
