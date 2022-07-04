//
//  STFont.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct STFont {
    /// 시간표 이름 등 강조할 때 사용하는 제목 글씨
    static let title: Font = .system(size: 17, weight: .bold)

    /// 강의명 등 제목을 표기할 때 사용하는 굵은 글씨
    static let subheading: Font = .system(size: 14, weight: .bold)

    /// 상세 정보를 표기할 때 사용하는 작은 글씨
    static let details: Font = .system(size: 12, weight: .regular)

    /// 상세 정보를 표기할 때 사용하는 작은 글씨
    static let filterCategory: Font = .system(size: 20, weight: .medium)
}
