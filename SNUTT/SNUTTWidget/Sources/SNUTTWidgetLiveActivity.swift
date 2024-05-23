//
//  SNUTTWidgetLiveActivity.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SNUTTWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SNUTTWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SNUTTWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SNUTTWidgetAttributes {
    fileprivate static var preview: SNUTTWidgetAttributes {
        SNUTTWidgetAttributes(name: "World")
    }
}

extension SNUTTWidgetAttributes.ContentState {
    fileprivate static var smiley: SNUTTWidgetAttributes.ContentState {
        SNUTTWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SNUTTWidgetAttributes.ContentState {
         SNUTTWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SNUTTWidgetAttributes.preview) {
   SNUTTWidgetLiveActivity()
} contentStates: {
    SNUTTWidgetAttributes.ContentState.smiley
    SNUTTWidgetAttributes.ContentState.starEyes
}
