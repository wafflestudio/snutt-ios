//
//  MyLectureListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

let lectureList = [
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

struct MyLectureListScene: View {
    let myDummyLectureList = lectureList

    var body: some View {
        LectureList(lectures: myDummyLectureList)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavBarButton(imageName: "nav.plus") {
                        print("menu tapped.")
                    }
                }
            }

        let _ = debugChanges()
    }
}

struct MyTimetableListScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabView {
                MyLectureListScene()
            }
        }
    }
}
