//
//  TaggedID.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Tagged

public enum LectureIDTag {}

/// 과목(강의) 식별 ID
///
/// 시간표 추가 여부에 관계없이 과목 자체를 식별한다.
public typealias LectureID = Tagged<LectureIDTag, String>

public enum TimetableLectureIDTag {}

/// 시간표 항목 ID
///
/// 시간표에 추가된 강의를 식별한다. 동일한 `LectureID`를 가진 강의가 여러 시간표에 추가된다면, 각각이 다른 `TimetableLectureID`를 가진다.
public typealias TimetableLectureID = Tagged<TimetableLectureIDTag, String>
