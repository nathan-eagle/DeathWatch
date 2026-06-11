import WidgetKit
import SwiftUI

struct LifeInlineWidget: Widget {
    let kind: String = "LifeInline"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeInlineView(entry: entry)
        }
        .configurationDisplayName("Life Inline")
        .description("Your remaining time, in a single line.")
        .supportedFamilies([.accessoryInline])
    }
}

struct LifeInlineView: View {
    let entry: LifeEntry

    var body: some View {
        Text("☠︎ \(entry.compactCountdownText)")
            .monospacedDigit()
            .containerBackground(for: .widget) {
                Color.clear
            }
    }
}
