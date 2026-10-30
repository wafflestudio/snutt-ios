//
//  EvaluationScores.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// The four detailed criteria of an evaluation.
enum EvaluationCriterion: CaseIterable, Hashable, Sendable {
    case gradeSatisfaction
    case teachingSkill
    case gains
    case lifeBalance
}

/// Detailed scores of an evaluation, one per ``EvaluationCriterion``.
struct EvaluationScores: Equatable, Sendable {
    let gradeSatisfaction: Double
    let teachingSkill: Double
    let gains: Double
    let lifeBalance: Double

    subscript(criterion: EvaluationCriterion) -> Double {
        switch criterion {
        case .gradeSatisfaction: gradeSatisfaction
        case .teachingSkill: teachingSkill
        case .gains: gains
        case .lifeBalance: lifeBalance
        }
    }
}
