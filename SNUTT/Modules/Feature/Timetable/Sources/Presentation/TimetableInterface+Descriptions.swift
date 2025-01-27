//
//  TimetableInterface+Descriptions.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

extension Lecture {
    var placesDescription: String? {
        let places = timePlaces
            .filter {
                !$0.place.isEmpty
            }
            .map {
                $0.place
            }
        if places.isEmpty {
            return nil
        }
        return places.joined(separator: ", ")
    }

    var timePlacesDescription: String {
        if timePlaces.isEmpty { return "" }
        return timePlaces.map { $0.description }.joined(separator: ", ")
    }

    var creditDescription: String? {
        // TODO:
        if let credit {
            "\(credit)학점"
        } else {
            nil
        }
    }

    public var instructorCreditDescription: String {
        let string = [instructor, creditDescription]
            .compactMap { $0 }
            .joined(separator: " / ")
        return string
    }
}

extension EvLecture {
    var avgRatingString: String {
        let avgRating = if let avgRating {
            String(format: "%.1f", avgRating)
        } else {
            "--"
        }
        return "\(avgRating) (\(evaluationCount ?? 0))"
    }
}
