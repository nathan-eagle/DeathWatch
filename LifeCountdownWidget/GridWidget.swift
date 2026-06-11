import WidgetKit
import SwiftUI

struct LifeGridWidget: Widget {
    let kind: String = "LifeGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeGridWidgetView(entry: entry)
        }
        .configurationDisplayName("Life Grid")
        .description("Your life in years, one dot each.")
        .supportedFamilies([.accessoryRectangular])
        .contentMarginsDisabled()
    }
}

struct LifeGridWidgetView: View {
    let entry: LifeEntry

    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.widgetContentMargins) private var systemMargins

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            titleRow
            LifeDotGrid(
                total: entry.totalYears,
                filledCount: entry.yearsLived,
                currentIndex: entry.yearsLived,
                rows: 4,
                accent: entry.accent,
                style: .gradient
            )
        }
        .padding(.top, min(systemMargins.top, 2))
        .padding(.bottom, min(systemMargins.bottom, 2))
        .padding(.leading, min(systemMargins.leading, 4))
        .padding(.trailing, min(systemMargins.trailing, 4))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .containerBackground(background, for: .widget)
    }

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("My Life")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer(minLength: 6)
            Text(entry.compactCountdownText)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private var background: AnyShapeStyle {
        renderingMode == .fullColor ? AnyShapeStyle(.black) : AnyShapeStyle(.clear)
    }

    private var accessibilitySummary: String {
        let currentYear = min(entry.yearsLived + 1, entry.totalYears)
        return "My Life, \(entry.countdownText) \(entry.unit.displayName.lowercased()), year \(currentYear) of \(entry.totalYears)"
    }
}
