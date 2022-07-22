//
//  SNUTTWidget.swift
//  SNUTTWidget
//
//  Created by 박신홍 on 2022/07/23.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct SNUTTWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        TimetableWidget()
    }
}

