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
        .contentMarginsDisabled()
    }
}

struct LifeBarWidgetView: View {
    let entry: LifeEntry

    @Environment(\.widgetContentMargins) private var systemMargins

    private var percentText: String {
        "\(Int((entry.percentLived * 100).rounded()))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("☠︎")
                    .font(.system(size: 11, weight: .semibold))
                Text(entry.unit.morbidName)
                    .font(DW.unitLabelFont)
                    .tracking(DW.unitLabelTracking)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Spacer(minLength: 1)

            Text(entry.countdownText)
                .font(DW.numberFont(36))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .widgetAccentable()

            Spacer(minLength: 2)

            HStack(spacing: 6) {
                LifeBar(progress: entry.percentLived, accent: entry.accent, height: 4)
                Text(percentText)
                    .font(DW.percentFont(11))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.top, min(systemMargins.top, 2))
        .padding(.bottom, min(systemMargins.bottom, 2))
        .padding(.leading, min(systemMargins.leading, 4))
        .padding(.trailing, min(systemMargins.trailing, 4))
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}
