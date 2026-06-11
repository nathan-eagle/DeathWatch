import Foundation
import WidgetKit

enum TimeUnit: String, CaseIterable {
    case hours
    case days
    case weeks

    var displayName: String {
        switch self {
        case .hours: return "HOURS LEFT"
        case .days: return "DAYS LEFT"
        case .weeks: return "WEEKS LEFT"
        }
    }

    var shortSuffix: String {
        switch self {
        case .hours: return "h"
        case .days: return "d"
        case .weeks: return "w"
        }
    }

    var morbidName: String {
        "\(displayName) TO LIVE"
    }

    var next: TimeUnit {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}

struct LifeEngine {
    static let defaults = UserDefaults(suiteName: "group.AerieVentures.DeathWatch") ?? .standard

    private enum Key {
        static let deathDate = "targetDate"
        static let birthDate = "birthDate"
        static let selectedUnit = "selectedTimeUnit"
        static let accentID = "accentID"
    }

    private init() {}

    // MARK: - Stored values

    static var deathDate: Date {
        get { defaults.object(forKey: Key.deathDate) as? Date ?? defaultDeathDate }
        set {
            defaults.set(newValue, forKey: Key.deathDate)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var birthDate: Date {
        get {
            if let stored = defaults.object(forKey: Key.birthDate) as? Date { return stored }
            return Calendar.current.date(byAdding: .year, value: -80, to: deathDate)
                ?? deathDate.addingTimeInterval(-80 * secondsPerYear)
        }
        set {
            defaults.set(newValue, forKey: Key.birthDate)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var selectedUnit: TimeUnit {
        get { TimeUnit(rawValue: defaults.string(forKey: Key.selectedUnit) ?? "") ?? .hours }
        set {
            defaults.set(newValue.rawValue, forKey: Key.selectedUnit)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var accentID: String {
        get { defaults.string(forKey: Key.accentID) ?? "coral" }
        set {
            defaults.set(newValue, forKey: Key.accentID)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static var defaultDeathDate: Date {
        var components = DateComponents()
        components.year = 2056
        components.month = 12
        components.day = 21
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date(timeIntervalSinceNow: 30 * secondsPerYear)
    }

    // MARK: - Time math

    private static let secondsPerHour: Double = 3_600
    private static let secondsPerDay: Double = 86_400
    private static let secondsPerWeek: Double = 604_800
    private static let secondsPerYear: Double = 365.2425 * 86_400

    static func secondsLeft(asOf date: Date = .now) -> TimeInterval {
        max(0, deathDate.timeIntervalSince(date))
    }

    static func hoursLeft(asOf date: Date = .now) -> Int {
        Int(secondsLeft(asOf: date) / secondsPerHour)
    }

    static func daysLeft(asOf date: Date = .now) -> Int {
        Int(secondsLeft(asOf: date) / secondsPerDay)
    }

    static func weeksLeft(asOf date: Date = .now) -> Int {
        Int(secondsLeft(asOf: date) / secondsPerWeek)
    }

    static func yearsLeft(asOf date: Date = .now) -> Double {
        secondsLeft(asOf: date) / secondsPerYear
    }

    static var totalYears: Int {
        let calendar = Calendar.current
        let whole = calendar.dateComponents([.year], from: birthDate, to: deathDate).year ?? 0
        let anniversary = calendar.date(byAdding: .year, value: whole, to: birthDate) ?? deathDate
        return min(130, max(1, whole + (anniversary < deathDate ? 1 : 0)))
    }

    static func yearsLived(asOf date: Date = .now) -> Double {
        max(0, date.timeIntervalSince(birthDate)) / secondsPerYear
    }

    static func currentAgeYears(asOf date: Date = .now) -> Int {
        let reference = max(birthDate, date)
        return Calendar.current.dateComponents([.year], from: birthDate, to: reference).year ?? 0
    }

    static func percentLived(asOf date: Date = .now) -> Double {
        let span = deathDate.timeIntervalSince(birthDate)
        guard span > 0 else { return 1 }
        return min(1, max(0, date.timeIntervalSince(birthDate) / span))
    }

    // MARK: - Countdown display

    static func countdownValue(for unit: TimeUnit, asOf date: Date = .now) -> Int {
        switch unit {
        case .hours: return hoursLeft(asOf: date)
        case .days: return daysLeft(asOf: date)
        case .weeks: return weeksLeft(asOf: date)
        }
    }

    static func formattedCountdown(for unit: TimeUnit, asOf date: Date = .now) -> String {
        formatted(countdownValue(for: unit, asOf: date))
    }

    static func compactCountdown(for unit: TimeUnit, asOf date: Date = .now) -> String {
        "\(formattedCountdown(for: unit, asOf: date))\(unit.shortSuffix) left"
    }

    static func formatted(_ value: Int) -> String {
        groupedFormatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    static var formattedDeathDate: String { mediumDateFormatter.string(from: deathDate) }
    static var formattedBirthDate: String { mediumDateFormatter.string(from: birthDate) }

    private static let groupedFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
