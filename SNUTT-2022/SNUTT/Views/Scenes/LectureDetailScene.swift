//
//  LectureDetailScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct LectureDetailScene: View {
    let viewModel: ViewModel
    let lecture: Lecture
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    VStack {
                        Group {
                            
                            HStack {
                                DetailLabel(text: "강의명")
                                DetailText(text: lecture.title)
                            }
                            HStack {
                                DetailLabel(text: "교수")
                                DetailText(text: lecture.instructor)
                            }
                            if lecture.isCustom {
                                HStack {
                                    DetailLabel(text: "학점")
                                    DetailText(text: String(lecture.credit))
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    DetailText(text: lecture.remark)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        
                    }
                    .padding()
                    
                    if !lecture.isCustom {
                        VStack {
                            Group {
                                
                                HStack {
                                    DetailLabel(text: "학과")
                                    DetailText(text: lecture.department)
                                }
                                HStack {
                                    DetailLabel(text: "학년")
                                    DetailText(text: lecture.academic_year)
                                }
                                HStack {
                                    DetailLabel(text: "학점")
                                    DetailText(text: String(lecture.credit))
                                }
                                HStack {
                                    DetailLabel(text: "분류")
                                    DetailText(text: lecture.classification)
                                }
                                HStack {
                                    DetailLabel(text: "구분")
                                    DetailText(text: lecture.category)
                                }
                                HStack {
                                    DetailLabel(text: "강좌번호")
                                    DetailText(text: lecture.course_number)
                                }
                                HStack {
                                    DetailLabel(text: "분반번호")
                                    DetailText(text: lecture.lecture_number)
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    DetailText(text: lecture.remark)
                                }
                            }
                            .padding(.vertical, 5)
                            
                        }
                        .padding()
                    }
                    
                    
                    VStack {
                        Text("시간 및 장소")
                            .padding(.leading, 5)
                            .font(STFont.detailLabel)
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(lecture.timePlaces) { timePlace in
                            VStack {
                                HStack {
                                    DetailLabel(text: "시간")
                                    DetailText(text: "\(timePlace.day.shortSymbol) \(timePlace.startTimeString) ~ \(timePlace.endTimeString)")
                                }
                                Spacer()
                                    .frame(height: 5)
                                HStack {
                                    DetailLabel(text: "장소")
                                    DetailText(text: timePlace.place)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    
                    DetailButton(text: "강의계획서") {
                        print("tap")
                    }
                    
                    DetailButton(text: "강의평") {
                        print("tap")
                    }
                    
                    DetailButton(text: "삭제") {
                        print("tap")
                    }
                    .foregroundColor(.red)
                    
                }
                .background(Color.white)
                
            }
            .padding(.vertical, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: TODO - Move elsewhere if necessary

struct DetailLabel: View {
    let text: String
    
    var body: some View {
        VStack{
            
            Text(text)
                .padding(.horizontal, 5)
                .padding(.trailing, 10)
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                .frame(maxWidth: 70, alignment: .leading)
        }
        
    }
}

struct DetailText: View {
    let text: String?
    
    var body: some View {
        Group {
            if let text = text, !text.isEmpty {
                Text(text)
            } else {
                Text("(없음)")
                    .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.6)))
            }
        }
        .font(.system(size: 16, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct DetailButton: View {
    let text: String
    let action: () -> Void
    
    struct DetailButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? Color(uiColor: .opaqueSeparator) : Color(uiColor: .systemBackground))
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
        }
        .buttonStyle(DetailButtonStyle())
    }
}

extension LectureDetailScene {
    class ViewModel: BaseViewModel {}
}

struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        LectureDetailScene(viewModel: .init(container: .preview), lecture: .preview)
    }
}
