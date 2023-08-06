//
//  STFont.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct STFont {
    /// 시간표 이름 등의 제목 (17, Bold)
    static let title: Font = .system(size: 17, weight: .bold)

    /// 비어있는 페이지에서의 제목 (16, Bold)
    static let subtitle: Font = .system(size: 16, weight: .bold)

    /// 강의명 등의 제목 (14, Bold)
    static let subheading: Font = .system(size: 14, weight: .bold)

    /// 강의 상세 화면의 제목 (14, Regular)
    static let detailLabel: Font = .system(size: 14, weight: .regular)

    /// 시간표 블록의 강의명 (11, Regular)
    static let lectureBlockTitle: Font = .system(size: 11, weight: .regular)

    /// 시간표 블록의 강의 장소 (11, Bold)
    static let lectureBlockPlace: Font = .system(size: 11, weight: .bold)

    /// 상세 정보 (12, Regular)
    static let details: Font = .system(size: 12, weight: .regular)

    /// 상세 정보 (12, Semibold)
    static let detailsSemibold: Font = .system(size: 12, weight: .semibold)
}
