import WidgetKit
import SwiftUI
import WatchKit

// Use the exact same app group and key
let sharedDefaults = UserDefaults(suiteName: "group.AerieVentures.DeathWatch") ?? UserDefaults.standard

// Keep the TimeUnit enum for the app to use
enum TimeUnit: String, CaseIterable {
    case hours, days, weeks
    
    var displayName: String {
        switch self {
        case .hours: return "HOURS LEFT TO LIVE"
        case .days: return "DAYS LEFT TO LIVE"
        case .weeks: return "WEEKS LEFT TO LIVE"
        }
    }
}

// Model for the countdown data - renamed to avoid conflicts
struct WidgetCountdownData {
    let targetDate: Date
    let selectedTimeUnit: TimeUnit
    
    // Format the target date as "MM/DD/YY, h:mm a"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, h:mm a"
        return formatter.string(from: targetDate)
    }
    
    // Calculate hours remaining
    var hoursRemaining: Int {
        let difference = targetDate.timeIntervalSinceNow
        return max(0, Int(difference / 3600))
    }
    
    // Calculate days remaining
    var daysRemaining: Int {
        return hoursRemaining / 24
    }
    
    // Calculate weeks remaining
    var weeksRemaining: Int {
        return daysRemaining / 7
    }
    
    // Get value based on selected time unit
    var displayValue: Int {
        switch selectedTimeUnit {
        case .hours: return hoursRemaining
        case .days: return daysRemaining
        case .weeks: return weeksRemaining
        }
    }
    
    // Create with the target date of December 21, 2056 at 6:00 PM
    static func create() -> WidgetCountdownData {
        // Read from shared defaults
        let savedDate = sharedDefaults.object(forKey: "targetDate") as? Date
        let timeUnitString = sharedDefaults.string(forKey: "selectedTimeUnit") ?? TimeUnit.hours.rawValue
        let timeUnit = TimeUnit(rawValue: timeUnitString) ?? .hours
        
        if let date = savedDate {
            print("Widget found saved date: \(date)") // Debug output
            return WidgetCountdownData(targetDate: date, selectedTimeUnit: timeUnit)
        } else {
            print("Widget using default date") // Debug output
            // Default date logic
            // Fall back to default date
            var dateComponents = DateComponents()
            dateComponents.year = 2056
            dateComponents.month = 12
            dateComponents.day = 21
            dateComponents.hour = 18
            dateComponents.minute = 0
            
            let calendar = Calendar.current
            let targetDate = calendar.date(from: dateComponents)!
            
            return WidgetCountdownData(targetDate: targetDate, selectedTimeUnit: timeUnit)
        }
    }
}

// Timeline Entry
struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdown: WidgetCountdownData
}

// Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        // Force read from shared defaults each time
        let countdown = WidgetCountdownData.create()
        return CountdownEntry(date: Date(), countdown: countdown)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> ()) {
        // Force read from shared defaults each time
        let countdown = WidgetCountdownData.create()
        let entry = CountdownEntry(date: Date(), countdown: countdown)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> ()) {
        // Create a timeline with multiple entries that updates more frequently
        var entries: [CountdownEntry] = []
        let currentDate = Date()
        
        // Add entries for the next few hours to ensure updates happen
        for hourOffset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            // Force read from shared defaults each time
            let countdown = WidgetCountdownData.create()
            let entry = CountdownEntry(date: entryDate, countdown: countdown)
            entries.append(entry)
        }
        
        // Update every hour at most
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// Widget View - reverted to original style
struct LifeCountdownWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    // Watch size categories
    private enum WatchSize {
        case ultra, large, medium, small
    }
    
    // Get current watch size category
    private var watchSizeCategory: WatchSize {
        let screenWidth = WKInterfaceDevice.current().screenBounds.width
        
        switch screenWidth {
        case 198...: return .ultra     // Ultra (198+)
        case 170..<198: return .large  // Larger watches (170-197)
        case 150..<170: return .medium // Medium watches (150-170)
        default: return .small         // Small watches (<150)
        }
    }
    
    // Size helpers that preserve Ultra experience
    private var symbolFontSize: CGFloat {
        switch watchSizeCategory {
        case .ultra: return 30  // Keep original size for Ultra
        case .large: return 28
        case .medium: return 25
        case .small: return 22
        }
    }
    
    private var titleFontSize: CGFloat {
        switch watchSizeCategory {
        case .ultra: return 13  // Keep original size for Ultra
        case .large: return 12
        case .medium: return 11
        case .small: return 9
        }
    }
    
    private var valueFontSize: CGFloat {
        switch watchSizeCategory {
        case .ultra: return 47  // Keep original size for Ultra
        case .large: return 44
        case .medium: return 40
        case .small: return 36
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: -18) { // Negative spacing to pull elements closer together
            HStack(spacing: 3) {
                Text("☠︎")
                    .font(.system(size: symbolFontSize))
                    .foregroundColor(.white)
                
                Text(entry.countdown.selectedTimeUnit.displayName)
                    .font(.system(size: titleFontSize, weight: .medium))
                    .minimumScaleFactor(watchSizeCategory == .small ? 0.7 : 0.9)
                    .lineLimit(1)
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(0.5) // letter spacing
            }
            .padding(.top, 4)
            
            Text("\(entry.countdown.displayValue)")
                .font(.system(size: valueFontSize, weight: .regular))
                .monospacedDigit()
                .foregroundColor(.white)
                .padding(.bottom, 4)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.black, for: .widget)
    }
}

// Widget Configuration
@main
struct LifeCountdownWidget: Widget {
    let kind: String = "LifeCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LifeCountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Death-Watch")
        .description("Shows hours left until your death date.")
        .supportedFamilies([.accessoryRectangular])
        .contentMarginsDisabled()
    }
}

// Widget Preview
struct LifeCountdownWidget_Previews: PreviewProvider {
    static var previews: some View {
        LifeCountdownWidgetEntryView(entry: CountdownEntry(date: Date(), countdown: WidgetCountdownData.create()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
