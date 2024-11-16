//
//  TimerModifier.swift
//  SNUTT
//
//  Created by 최유림 on 11/16/24.
//

import Combine
import SwiftUI

struct TimerModifier: ViewModifier {
    
    /// Time limitation for timer. 180 seconds by default.
    var initialTime: Int = 180
    @Binding var timeOut: Bool
    @Binding var remainingTime: Int
    @Binding var restart: Bool

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var currentTimer: Cancellable?
    
    func body(content: Content) -> some View {
        content
            .onReceive(timer) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    currentTimer?.cancel()
                    timeOut = true
                    restart = false
                }
            }
            .onAppear {
                startTimer()
            }
            .onChange(of: restart) { start in
                if start {
                    startTimer()
                }
            }
    }
    
    private func startTimer() {
        timeOut = false
        remainingTime = initialTime
        currentTimer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
        currentTimer = timer.connect()
    }
}

extension View {
    func timer(initialTime: Int = 180, timeOut: Binding<Bool>, remainingTime: Binding<Int>, restart: Binding<Bool> = .constant(true)) -> some View {
        modifier(TimerModifier(initialTime: initialTime, timeOut: timeOut, remainingTime: remainingTime, restart: restart))
    }
}
