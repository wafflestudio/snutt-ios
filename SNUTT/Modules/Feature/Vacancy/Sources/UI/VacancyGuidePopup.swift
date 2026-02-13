//
//  VacancyGuidePopup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct VacancyGuidePopup: View {
    var body: some View {
        ImageGuidePopup(
            guideImages: [
                VacancyAsset.vacancyGuide1.image,
                VacancyAsset.vacancyGuide2.image,
                VacancyAsset.vacancyGuide3.image,
                VacancyAsset.vacancyGuide4.image,
            ]
        )
    }
}

#Preview {
    VacancyGuidePopup()
}
