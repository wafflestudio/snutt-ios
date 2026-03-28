//
//  TimetableID.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Tagged

public enum TimetableIDTag {}

/// 시간표 식별 ID
public typealias TimetableID = Tagged<TimetableIDTag, String>
