import SwiftUI
import WatchKit

struct CrownDatePickerScreen: View {
    enum Kind {
        case birth
        case death

        var title: String {
            switch self {
            case .birth: return "Birth Date"
            case .death: return "Death Date"
            }
        }

        var yearRange: ClosedRange<Int> {
            let currentYear = Calendar.current.component(.year, from: .now)
            switch self {
            case .birth: return 1900...currentYear
            case .death: return currentYear...2120
            }
        }

        var hour: Int {
            switch self {
            case .birth: return 0
            case .death: return 18
            }
        }

        var initialDate: Date {
            switch self {
            case .birth: return LifeEngine.birthDate
            case .death: return LifeEngine.deathDate
            }
        }

        var lowerBound: Date {
            switch self {
            case .birth:
                return Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
            case .death:
                return .now
            }
        }

        var upperBound: Date {
            switch self {
            case .birth:
                return .now
            case .death:
                return Calendar.current.date(from: DateComponents(year: 2120, month: 12, day: 31, hour: 18)) ?? .distantFuture
            }
        }

        func persist(_ date: Date) {
            switch self {
            case .birth: LifeEngine.birthDate = date
            case .death: LifeEngine.deathDate = date
            }
        }
    }

    private enum Segment {
        case month, day, year
    }

    let kind: Kind
    var onSave: ((Date) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var month: Int
    @State private var day: Int
    @State private var year: Int
    @State private var focusedSegment: Segment = .year
    @State private var crownValue: Double

    private static let shortMonths: [String] = DateFormatter().shortMonthSymbols ?? [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ]

    init(kind: Kind, onSave: ((Date) -> Void)? = nil) {
        self.kind = kind
        self.onSave = onSave
        let clamped = min(max(kind.initialDate, kind.lowerBound), kind.upperBound)
        let calendar = Calendar.current
        let initialYear = calendar.component(.year, from: clamped)
        _month = State(initialValue: calendar.component(.month, from: clamped))
        _day = State(initialValue: calendar.component(.day, from: clamped))
        _year = State(initialValue: initialYear)
        _crownValue = State(initialValue: Double(initialYear))
    }

    private var accent: Accent { AccentStore.current }

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            HStack(spacing: 5) {
                segmentChip(text: monthText, segment: .month)
                segmentChip(text: String(format: "%02d", day), segment: .day)
                segmentChip(text: String(year), segment: .year)
            }
            .focusable()
            .digitalCrownRotation(
                $crownValue,
                from: crownRange.lowerBound,
                through: crownRange.upperBound,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { _, newValue in
                update(to: Int(newValue.rounded()))
            }

            Text(caption)
                .font(.system(size: 12, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.tertiary)
                .contentTransition(.numericText())

            Spacer(minLength: 0)

            Button(action: save) {
                Text("Set")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(accent.linearGradient, in: Capsule())
            }
            .buttonStyle(PressableCapsuleStyle())
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 4)
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func segmentChip(text: String, segment: Segment) -> some View {
        let isFocused = focusedSegment == segment
        return Text(text)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .contentTransition(.numericText())
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .snappy(duration: 0.18), value: text)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isFocused ? accent.solid.opacity(0.25) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isFocused ? accent.solid : Color.clear, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .onTapGesture { focus(segment) }
    }

    private var monthText: String {
        let index = min(max(month, 1), 12) - 1
        return Self.shortMonths.indices.contains(index) ? Self.shortMonths[index] : String(month)
    }

    private var caption: String {
        let calendar = Calendar.current
        switch kind {
        case .birth:
            let age = max(0, calendar.dateComponents([.year], from: composedDate, to: .now).year ?? 0)
            return age == 1 ? "1 year old" : "\(age) years old"
        case .death:
            let years = max(0, calendar.dateComponents([.year], from: .now, to: composedDate).year ?? 0)
            if years == 0 { return "less than a year away" }
            return years == 1 ? "1 year away" : "\(years) years away"
        }
    }

    private var crownRange: ClosedRange<Double> {
        switch focusedSegment {
        case .month: return 1...12
        case .day: return 1...Double(daysInCurrentMonth)
        case .year: return Double(kind.yearRange.lowerBound)...Double(kind.yearRange.upperBound)
        }
    }

    private var daysInCurrentMonth: Int {
        daysIn(month: month, year: year)
    }

    private func daysIn(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: year, month: month)),
              let range = calendar.range(of: .day, in: .month, for: date) else { return 31 }
        return range.count
    }

    private var composedDate: Date {
        let components = DateComponents(year: year, month: month, day: day, hour: kind.hour, minute: 0)
        return Calendar.current.date(from: components) ?? kind.initialDate
    }

    private func focus(_ segment: Segment) {
        guard segment != focusedSegment else { return }
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .snappy(duration: 0.2)) {
            focusedSegment = segment
        }
        crownValue = currentValue(of: segment)
        WKInterfaceDevice.current().play(.click)
    }

    private func currentValue(of segment: Segment) -> Double {
        switch segment {
        case .month: return Double(month)
        case .day: return Double(day)
        case .year: return Double(year)
        }
    }

    private func update(to rawValue: Int) {
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.15)) {
            switch focusedSegment {
            case .month: month = min(max(1, rawValue), 12)
            case .day: day = min(max(1, rawValue), daysInCurrentMonth)
            case .year: year = min(max(kind.yearRange.lowerBound, rawValue), kind.yearRange.upperBound)
            }
            normalize()
        }
    }

    private func normalize() {
        day = min(day, daysIn(month: month, year: year))
        let candidate = composedDate
        let bounded = min(max(candidate, kind.lowerBound), kind.upperBound)
        guard abs(bounded.timeIntervalSince(candidate)) > 1 else { return }
        let calendar = Calendar.current
        month = calendar.component(.month, from: bounded)
        day = calendar.component(.day, from: bounded)
        year = calendar.component(.year, from: bounded)
    }

    private func save() {
        let date = min(max(composedDate, kind.lowerBound), kind.upperBound)
        kind.persist(date)
        onSave?(date)
        WKInterfaceDevice.current().play(.success)
        dismiss()
    }
}

private struct PressableCapsuleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Birth Date") {
    NavigationStack {
        CrownDatePickerScreen(kind: .birth)
    }
}

#Preview("Death Date") {
    NavigationStack {
        CrownDatePickerScreen(kind: .death)
    }
}
