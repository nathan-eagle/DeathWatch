import WidgetKit
import SwiftUI

struct LifeBarWidget: Widget {
    let kind: String = "LifeCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeBarWidgetView(entry: entry)
        }
        .configurationDisplayName("Life Bar")
        .description("Time left, with your life as a progress bar.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct LifeBarWidgetView: View {
    let entry: LifeEntry

    private var percentText: String {
        "\(Int((entry.percentLived * 100).rounded()))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("☠︎")
                    .font(.system(size: 10, weight: .semibold))
                Text(entry.unit.displayName)
                    .font(DW.unitLabelFont)
                    .tracking(DW.unitLabelTracking)
            }
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Spacer(minLength: 2)

            Text(entry.countdownText)
                .font(DW.numberFont(28))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .widgetAccentable()

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                LifeBar(progress: entry.percentLived, accent: entry.accent, height: 4.5)
                Text(percentText)
                    .font(DW.percentFont(11))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}
