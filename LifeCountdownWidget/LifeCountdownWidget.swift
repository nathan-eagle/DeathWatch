import WidgetKit
import SwiftUI

struct LifeEntry: TimelineEntry {
    let date: Date
    let unit: TimeUnit
    let countdownValue: Int
    let countdownText: String
    let compactCountdownText: String
    let percentLived: Double
    let currentAge: Int
    let totalYears: Int
    let yearsLived: Int
    let deathDateText: String
    let accent: Accent

    static func make(for date: Date) -> LifeEntry {
        let unit = LifeEngine.selectedUnit
        return LifeEntry(
            date: date,
            unit: unit,
            countdownValue: LifeEngine.countdownValue(for: unit, asOf: date),
            countdownText: LifeEngine.formattedCountdown(for: unit, asOf: date),
            compactCountdownText: LifeEngine.compactCountdown(for: unit, asOf: date),
            percentLived: LifeEngine.percentLived(asOf: date),
            currentAge: LifeEngine.currentAgeYears(asOf: date),
            totalYears: LifeEngine.totalYears,
            yearsLived: LifeEngine.currentAgeYears(asOf: date),
            deathDateText: LifeEngine.formattedDeathDate,
            accent: Accent.preset(id: LifeEngine.accentID)
        )
    }
}

struct LifeTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeEntry {
        .make(for: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeEntry) -> Void) {
        completion(.make(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let entries: [LifeEntry] = (0..<12).compactMap { hourOffset in
            calendar.date(byAdding: .hour, value: hourOffset, to: now).map { LifeEntry.make(for: $0) }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

@main
struct DeathWatchWidgets: WidgetBundle {
    var body: some Widget {
        LifeGridWidget()
        LifeBarWidget()
        LifeRingCircularWidget()
        LifeRingCornerWidget()
        LifeInlineWidget()
    }
}
