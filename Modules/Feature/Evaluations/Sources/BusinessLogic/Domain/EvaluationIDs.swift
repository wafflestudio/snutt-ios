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
