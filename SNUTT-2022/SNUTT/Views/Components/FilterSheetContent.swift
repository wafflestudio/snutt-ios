//
//  FilterSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/27.
//

import SwiftUI

struct FilterSheetContent: View {
    @State var selectedCategory: STTagType = .academicYear
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack(spacing: 20) {
                    ForEach(STTagType.allCases, id: \.self) { tag in
                        let isSelected = selectedCategory == tag
                        Button {
                            selectedCategory = tag
                        } label: {
                            Text(tag.typeStr)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(isSelected ? Color(uiColor: .label.withAlphaComponent(0.7)) : Color.gray)
                        .buttonStyle(.bordered)
                        .tint(isSelected ? STColor.cyan : Color.white)
                    }
                }
                .padding()
                .frame(maxWidth: 130)
                
                Divider()
                
                ScrollView {
                    Group {
                        ForEach(1 ..< 100) { num in
                            Button {} label: {
                                HStack {
                                    Image("checkmark.circle.\(num % 4 == 0 ? "tick" : "untick")")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .padding(.trailing, 5)
                                    Text("\(num)학년")
                                        .font(.system(size: 15))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.trailing)
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.03),
                    .init(color: .black, location: 0.97),
                    .init(color: .clear, location: 1),
                ]), startPoint: .top, endPoint: .bottom))
            }
            
            Button {} label: {
                Text("필터 적용")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .padding(.bottom, 10)
            .tint(STColor.cyan)
        }
    }
}

struct FilterSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetContent()
    }
}

enum STTagType: String, CaseIterable {
    case academicYear = "academic_year"
    case classification
    case credit
    case department
    case category
    case etc
    
    var typeStr: String {
        switch self {
        case .academicYear: return "학년"
        case .classification: return "분류"
        case .credit: return "학점"
        case .department: return "학과"
        case .category: return "교양분류"
        case .etc: return "기타"
        }
    }
}
