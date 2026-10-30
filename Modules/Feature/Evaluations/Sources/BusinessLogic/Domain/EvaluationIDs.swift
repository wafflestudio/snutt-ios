//
//  EvaluationIDs.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Tagged

/// A tag that gives lecture evaluation identifiers strong type safety.
enum EvaluationIDTag {}

/// A strongly typed identifier for a lecture evaluation.
typealias EvaluationID = Tagged<EvaluationIDTag, Int64>

/// A tag that gives evaluation lecture identifiers strong type safety.
enum EvaluationLectureIDTag {}

/// A strongly typed identifier for a lecture in the evaluation domain.
typealias EvaluationLectureID = Tagged<EvaluationLectureIDTag, Int64>

/// A tag that gives semester lecture identifiers strong type safety.
enum SemesterLectureIDTag {}

/// A strongly typed identifier for a lecture offered in a specific semester.
typealias SemesterLectureID = Tagged<SemesterLectureIDTag, Int64>

/// A tag that gives search tag identifiers strong type safety.
enum SearchTagIDTag {}

/// A strongly typed identifier for a lecture search filter tag.
typealias SearchTagID = Tagged<SearchTagIDTag, Int64>
