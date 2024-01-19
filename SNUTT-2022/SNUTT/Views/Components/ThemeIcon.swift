//
//  CustomThemeIcon.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI

struct ThemeIcon: View {
    var theme: Theme
    var body: some View {
        VStack {
            ThemeBoxes(colors: theme.colors)
                .frame(width: 80, height: 78)
                .cornerRadius(6)
        }
    }
}

struct ThemeBoxes: View {
    var colors: [LectureColor]
    var body: some View {
        switch(colors.count) {
        case 1: OneColorBox(color: colors[0].fg)
        case 2: HStack(spacing:0) {
            OneColorBox(color: colors[0].fg)
            OneColorBox(color: colors[1].fg)
        }
        case 3: HStack(spacing:0) {
            OneColorBox(color: colors[0].fg)
            OneColorBox(color: colors[1].fg)
            OneColorBox(color: colors[2].fg)
        }
        case 4: HStack(spacing:0) {
            OneColorBox(color: colors[0].fg)
            TwoColorBox(color1: colors[1].fg, color2: colors[2].fg)
            OneColorBox(color: colors[3].fg)
        }
        case 5: HStack(spacing:0) {
            TwoColorBox(color1: colors[0].fg, color2: colors[1].fg)
            OneColorBox(color: colors[2].fg)
            TwoColorBox(color1: colors[3].fg, color2: colors[4].fg)
        }
        case 6: HStack(spacing:0) {
            OneColorBox(color: colors[0].fg)
            TwoColorBox(color1: colors[1].fg, color2: colors[2].fg)
            TwoColorBox(color1: colors[3].fg, color2: colors[4].fg)
            OneColorBox(color: colors[5].fg)
        }
        case 7: HStack(spacing:0) {
            TwoColorBox(color1: colors[0].fg, color2: colors[1].fg)
            ThreeColorBox(color1: colors[2].fg, color2: colors[3].fg, color3: colors[4].fg)
            TwoColorBox(color1: colors[5].fg, color2: colors[6].fg)
        }
        case 8: HStack(spacing:0) {
            ThreeColorBox(color1: colors[0].fg, color2: colors[1].fg, color3: colors[2].fg)
            TwoColorBox(color1: colors[3].fg, color2: colors[4].fg)
            ThreeColorBox(color1: colors[5].fg, color2: colors[6].fg, color3: colors[7].fg)
        }
        case 9: HStack(spacing:0) {
            OneColorBox(color: colors[0].fg)
            ThreeColorBox(color1: colors[1].fg, color2: colors[2].fg, color3: colors[3].fg)
            ThreeColorBox(color1: colors[4].fg, color2: colors[5].fg, color3: colors[6].fg)
            TwoColorBox(color1: colors[7].fg, color2: colors[8].fg)
        }
        default: VStack {
            Text("unavailable")
        }
        }
    }
}

struct OneColorBox: View {
    var color: Color
    var body: some View {
        Rectangle()
            .fill(color)
    }
}

struct TwoColorBox: View {
    var color1: Color
    var color2: Color
    var body: some View {
        VStack(spacing:0) {
            Rectangle()
                .fill(color1)
            Rectangle()
                .fill(color2)
        }
    }
}

struct ThreeColorBox: View {
    var color1: Color
    var color2: Color
    var color3: Color
    var body: some View {
        VStack(spacing:0) {
            Rectangle()
                .fill(color1)
            Rectangle()
                .fill(color2)
            Rectangle()
                .fill(color3)
        }
    }
}
