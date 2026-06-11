import SwiftUI
import WatchKit

struct GridHeroPage: View {
    @EnvironmentObject private var accentStore: AccentStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsPercentLeft = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            content(asOf: context.date)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: togglePercentMode)
        .containerBackground(.black, for: .tabView)
        .onAppear(perform: syncAccent)
    }

    private func content(asOf date: Date) -> some View {
        let accent = accentStore.accent
        let livedPercent = Int((LifeEngine.percentLived(asOf: date) * 100).rounded())
        let shownPercent = showsPercentLeft ? 100 - livedPercent : livedPercent
        let unit = LifeEngine.selectedUnit
        let totalYears = LifeEngine.totalYears
        let filledYears = min(totalYears, LifeEngine.currentAgeYears(asOf: date))

        return VStack(spacing: 4) {
            VStack(spacing: 1) {
                Text("\(shownPercent)%")
                    .font(DW.heroFont(40))
                    .monospacedDigit()
                    .foregroundStyle(accent.linearGradient)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                DW.unitLabel(showsPercentLeft ? "of life left" : "of life lived")
                    .contentTransition(.opacity)
            }
            LifeDotGrid(
                total: totalYears,
                filledCount: filledYears,
                currentIndex: filledYears,
                rows: gridRows(for: totalYears),
                accent: accent,
                style: .gradient,
                animateIn: true
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(LifeEngine.formattedCountdown(for: unit, asOf: date))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                DW.unitLabel(unit.displayName)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
    }

    private func gridRows(for total: Int) -> Int {
        guard total > 0 else { return 1 }
        let candidates: [(rows: Int, notch: Int)] = (7...10).map { rows in
            let columns = max(1, Int((Double(total) / Double(rows)).rounded(.up)))
            let rendered = max(1, Int((Double(total) / Double(columns)).rounded(.up)))
            return (rendered, columns * rendered - total)
        }
        return candidates.min { ($0.notch, $0.rows) < ($1.notch, $1.rows) }?.rows ?? 8
    }

    private func togglePercentMode() {
        let animation: Animation = reduceMotion
            ? .easeOut(duration: 0.2)
            : .snappy(duration: 0.3)
        withAnimation(animation) {
            showsPercentLeft.toggle()
        }
        WKInterfaceDevice.current().play(.click)
    }

    private func syncAccent() {
        if accentStore.accent.id != LifeEngine.accentID {
            accentStore.select(Accent.preset(id: LifeEngine.accentID))
        }
    }
}

#Preview {
    GridHeroPage()
        .environmentObject(AccentStore())
}
