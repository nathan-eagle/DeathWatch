import WidgetKit
import SwiftUI

// MARK: - Circular

struct LifeRingCircularWidget: Widget {
    let kind: String = "LifeRingCircular"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeRingCircularView(entry: entry)
        }
        .configurationDisplayName("Life Ring")
        .description("Percent of life lived, with your current and final age.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct LifeRingCircularView: View {
    let entry: LifeEntry

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            LifeRing(
                progress: entry.percentLived,
                accent: entry.accent,
                gradient: renderingMode == .fullColor
            ) {
                VStack(spacing: -1) {
                    Text(percentText)
                        .font(DW.numberFont(19))
                        .monospacedDigit()
                        .minimumScaleFactor(0.8)
                    Text(ageSpanText)
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
            }
        }
        .widgetLabel(entry.compactCountdownText)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var percentText: String {
        "\(Int((entry.percentLived * 100).rounded()))"
    }

    private var ageSpanText: String {
        "\(entry.currentAge)·\(entry.totalYears)"
    }
}

// MARK: - Corner

struct LifeRingCornerWidget: Widget {
    let kind: String = "LifeRingCorner"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeRingCornerView(entry: entry)
        }
        .configurationDisplayName("Life Ring (Corner)")
        .description("Days left, with life progress curved into the corner.")
        .supportedFamilies([.accessoryCorner])
    }
}

struct LifeRingCornerView: View {
    let entry: LifeEntry

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        Text(daysLeftText)
            .font(DW.numberFont(15))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .widgetCurvesContent()
            .widgetLabel {
                Gauge(value: entry.percentLived) {
                    Text("DAYS LEFT")
                }
                .tint(gaugeTint)
                .widgetAccentable()
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
    }

    private var daysLeftText: String {
        let days = LifeEngine.daysLeft(asOf: entry.date)
        guard days >= 10_000 else { return LifeEngine.formatted(days) }
        let thousands = Double(days) / 1_000
        let text = thousands >= 100
            ? String(format: "%.0fk", thousands)
            : String(format: "%.1fk", thousands)
        return text.replacingOccurrences(of: ".0k", with: "k")
    }

    private var gaugeTint: AnyShapeStyle {
        renderingMode == .fullColor
            ? AnyShapeStyle(Gradient(colors: [entry.accent.gradientStart, entry.accent.gradientEnd]))
            : AnyShapeStyle(entry.accent.solid)
    }
}
