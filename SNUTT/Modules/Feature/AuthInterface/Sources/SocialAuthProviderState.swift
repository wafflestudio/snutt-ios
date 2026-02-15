//
//  SocialAuthProviderState.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct SocialAuthProviderState: Sendable {
    public let apple: State
    public let facebook: State
    public let google: State
    public let kakao: State
    public let local: State

    public enum State: Sendable {
        case linked
        case unlinked
    }
}
