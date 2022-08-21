//
//  SNUTTWidget.swift
//  SNUTTWidget
//
//  Created by 박신홍 on 2022/07/23.
//

import Intents
import SwiftUI
import WidgetKit

@main
struct SNUTTWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TimetableWidget()
    }
}
