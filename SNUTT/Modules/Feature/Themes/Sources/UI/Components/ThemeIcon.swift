//
//  ThemeIcon.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface

struct ThemeIcon: View {
    var theme: Theme
    var body: some View {
        VStack {
            ThemeBoxes(colors: theme.colors)
                .cornerRadius(6)
        }
    }
}

private struct ThemeBoxes: View {
    var colors: [LectureColor]
    var body: some View {
        switch colors.count {
        case 1: OneColorBox(color: colors[0].bg)
        case 2:
            HStack(spacing: 0) {
                OneColorBox(color: colors[0].bg)
                OneColorBox(color: colors[1].bg)
            }
        case 3:
            HStack(spacing: 0) {
                OneColorBox(color: colors[0].bg)
                OneColorBox(color: colors[1].bg)
                OneColorBox(color: colors[2].bg)
            }
        case 4:
            HStack(spacing: 0) {
                OneColorBox(color: colors[0].bg)
                TwoColorBox(color1: colors[1].bg, color2: colors[2].bg)
                OneColorBox(color: colors[3].bg)
            }
        case 5:
            HStack(spacing: 0) {
                TwoColorBox(color1: colors[0].bg, color2: colors[1].bg)
                OneColorBox(color: colors[2].bg)
                TwoColorBox(color1: colors[3].bg, color2: colors[4].bg)
            }
        case 6:
            HStack(spacing: 0) {
                OneColorBox(color: colors[0].bg)
                TwoColorBox(color1: colors[1].bg, color2: colors[2].bg)
                TwoColorBox(color1: colors[3].bg, color2: colors[4].bg)
                OneColorBox(color: colors[5].bg)
            }
        case 7:
            HStack(spacing: 0) {
                TwoColorBox(color1: colors[0].bg, color2: colors[1].bg)
                ThreeColorBox(color1: colors[2].bg, color2: colors[3].bg, color3: colors[4].bg)
                TwoColorBox(color1: colors[5].bg, color2: colors[6].bg)
            }
        case 8:
            HStack(spacing: 0) {
                ThreeColorBox(color1: colors[0].bg, color2: colors[1].bg, color3: colors[2].bg)
                TwoColorBox(color1: colors[3].bg, color2: colors[4].bg)
                ThreeColorBox(color1: colors[5].bg, color2: colors[6].bg, color3: colors[7].bg)
            }
        case 9:
            HStack(spacing: 0) {
                OneColorBox(color: colors[0].bg)
                ThreeColorBox(color1: colors[1].bg, color2: colors[2].bg, color3: colors[3].bg)
                ThreeColorBox(color1: colors[4].bg, color2: colors[5].bg, color3: colors[6].bg)
                TwoColorBox(color1: colors[7].bg, color2: colors[8].bg)
            }
        default:
            VStack {
                Text("unavailable")
            }
        }
    }
}

private struct OneColorBox: View {
    var color: Color
    var body: some View {
        Rectangle()
            .fill(color)
    }
}

private struct TwoColorBox: View {
    var color1: Color
    var color2: Color
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color1)
            Rectangle()
                .fill(color2)
        }
    }
}

private struct ThreeColorBox: View {
    var color1: Color
    var color2: Color
    var color3: Color
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color1)
            Rectangle()
                .fill(color2)
            Rectangle()
                .fill(color3)
        }
    }
}
