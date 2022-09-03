//
//  SearchLectureList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/04.
//

import SwiftUI

struct SearchLectureList: View {
    let data: [Lecture]
    let fetchMore: () async -> Void
    let addLecture: (Lecture) async -> Void
    @Binding var selected: Lecture?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data) { lecture in
                    SearchLectureCell(lecture: lecture, selected: selected?.id == lecture.id, addLecture: addLecture)
                        .task {
                            if lecture.id == data.last?.id {
                                await fetchMore()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selected?.id != lecture.id {
                                selected = lecture
                            }
                        }
                }
            }
        }
        
        let _ = debugChanges()
    }
}
