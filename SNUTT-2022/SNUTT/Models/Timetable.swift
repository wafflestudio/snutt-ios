//
//  Tiemtable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

class Timetable: ObservableObject {
    var lectures: [Lecture]
    
    init(lectures: [Lecture]) {
        self.lectures = lectures
    }
}
