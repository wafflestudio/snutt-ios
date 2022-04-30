//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

class AppState {}

/// For demo purpose. To be removed.
class DummyAppState {
    static let shared = DummyAppState()

    let lectures = [
        Lecture(id: 1, title: "컴파일러", instructor: "전병곤", timePlaces: [
            TimePlace(day: Weekday(rawValue: 1)!, start: 5.5, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 3)!, start: 3.15, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 3)!, start: 4.70, len: 1.5, place: "302-123"),
        ]),
        Lecture(id: 2, title: "컴퓨터구조", instructor: "김진수", timePlaces: [
            TimePlace(day: Weekday(rawValue: 2)!, start: 7.5, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 4)!, start: 7.5, len: 1.5, place: "302-123"),
        ]),
    ]

    var dummyLecture: Lecture {
        lectures[0]
    }
}
