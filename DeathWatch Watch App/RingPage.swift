//
//  RingPage.swift
//  DeathWatch Watch App
//

import SwiftUI
import WatchKit

struct RingPage: View {
    @State private var unit: TimeUnit = LifeEngine.selectedUnit
    @State private var accent: Accent = AccentStore.current
    @State private var ringProgress: Double = 0
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.everyMinute) { context in
                VStack(spacing: 10) {
                    ring(side: proxy.size.width * 0.7, date: context.date)
                    Text(LifeEngine.formattedDeathDate)
                        .font(.system(size: 13, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear(perform: refresh)
    }

    private func ring(side: CGFloat, date: Date) -> some View {
        LifeRing(progress: ringProgress, accent: accent, lineWidthRatio: 0.085, gradient: true) {
            VStack(spacing: 2) {
                Text(LifeEngine.formattedCountdown(for: unit, asOf: date))
                    .font(DW.numberFont(side * 0.26))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .contentTransition(reduceMotion ? .opacity : .numericText())
                DW.unitLabel(unit.displayName)
                    .contentTransition(.opacity)
            }
            .frame(maxWidth: side * 0.76)
        }
        .frame(width: side, height: side)
        .contentShape(Circle())
        .onTapGesture(perform: cycleUnit)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Time remaining")
        .accessibilityValue("\(LifeEngine.formattedCountdown(for: unit, asOf: date)) \(unit.displayName.lowercased())")
        .accessibilityHint("Changes the time unit")
    }

    private func cycleUnit() {
        let next = unit.next
        LifeEngine.selectedUnit = next
        let animation: Animation = reduceMotion
            ? .easeOut(duration: 0.2)
            : .spring(response: 0.4, dampingFraction: 0.8)
        withAnimation(animation) {
            unit = next
        }
        WKInterfaceDevice.current().play(.click)
    }

    private func refresh() {
        unit = LifeEngine.selectedUnit
        accent = AccentStore.current
        let target = LifeEngine.percentLived()
        let animated = !hasAppeared && !reduceMotion
        hasAppeared = true
        if animated {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                ringProgress = target
            }
        } else {
            ringProgress = target
        }
    }
}

#Preview {
    RingPage()
}
