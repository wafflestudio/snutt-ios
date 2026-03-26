//
//  UserID.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Tagged

public enum UserIDTag {}

/// 서버 DB User 테이블의 Primary Key (MongoDB ObjectId)
///
/// 시간표 소유자 식별, 친구 관계, 알림 대상 등에서 사용된다.
public typealias UserID = Tagged<UserIDTag, String>

public enum UsernameTag {}

/// 로그인 아이디 (username)
///
/// 사용자가 로컬 회원가입 시 설정하는 인증 식별자이다.
public typealias Username = Tagged<UsernameTag, String>
