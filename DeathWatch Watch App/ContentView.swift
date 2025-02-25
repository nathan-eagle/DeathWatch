import SwiftUI
import WidgetKit

// Create a UserDefaults suite that can be shared with the widget
let sharedDefaults = UserDefaults(suiteName: "group.AerieVentures.DeathWatch") ?? UserDefaults.standard

// Add this enum at the top of the file, after the imports (make sure it matches the widget one)
enum TimeUnit: String, CaseIterable {
    case hours, days, weeks
    
    var displayName: String {
        switch self {
        case .hours: return "HOURS LEFT"
        case .days: return "DAYS LEFT"
        case .weeks: return "WEEKS LEFT"
        }
    }
}

struct ContentView: View {
    @State private var targetDate = sharedDefaults.object(forKey: "targetDate") as? Date ?? getDefaultTargetDate()
    @State private var selectedTimeUnit: TimeUnit = {
        let savedValue = sharedDefaults.string(forKey: "selectedTimeUnit") ?? TimeUnit.hours.rawValue
        return TimeUnit(rawValue: savedValue) ?? .hours
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Time remaining displays
                VStack(spacing: 12) {
                    ForEach(TimeUnit.allCases, id: \.self) { unit in
                        Button {
                            selectedTimeUnit = unit
                            // Save to shared defaults
                            sharedDefaults.set(unit.rawValue, forKey: "selectedTimeUnit")
                            sharedDefaults.synchronize()
                            
                            // Force reload widget
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            timeRemainingView(title: unit.displayName, value: valueForUnit(unit))
                                .padding(2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(unit == selectedTimeUnit ? Color.orange : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(10)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // Date display and navigation
                VStack(spacing: 6) {
                    Text("Death Date set to \(formattedDate)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: ManualDatePickerScreen(initialDate: targetDate, onDateSelected: { newDate in
                        targetDate = newDate
                        // Save to shared UserDefaults
                        sharedDefaults.set(newDate, forKey: "targetDate")
                        sharedDefaults.synchronize() // Force immediate write
                        
                        // Force reload widget
                        WidgetCenter.shared.reloadAllTimelines()
                    })) {
                        Text("Change Death Date")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper to get the value for a given time unit
    private func valueForUnit(_ unit: TimeUnit) -> Int {
        switch unit {
        case .hours: return hoursRemaining
        case .days: return daysRemaining
        case .weeks: return weeksRemaining
        }
    }
    
    // Helper views and computed properties
    func timeRemainingView(title: String, value: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
            Spacer()
            Text("\(value)")
                .font(.system(size: 12, design: .monospaced))
        }
    }
    
    var hoursRemaining: Int {
        let difference = targetDate.timeIntervalSinceNow
        return max(0, Int(difference / 3600))
    }
    
    var daysRemaining: Int {
        return hoursRemaining / 24
    }
    
    var weeksRemaining: Int {
        return daysRemaining / 7
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: targetDate)
    }
    
    static func getDefaultTargetDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2056
        dateComponents.month = 12
        dateComponents.day = 21
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        return Calendar.current.date(from: dateComponents) ?? Date().addingTimeInterval(86400 * 365 * 30)
    }
}

// Custom date picker screen that doesn't use DatePicker
struct ManualDatePickerScreen: View {
    let initialDate: Date
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var year: Int
    @State private var month: Int
    @State private var day: Int
    @State private var focusedField: DateComponent = .year
    
    // For the Digital Crown rotation which requires Double
    @State private var crownValue: Double = 0
    
    // Track which date component is focused
    private enum DateComponent {
        case month, day, year
    }
    
    init(initialDate: Date, onDateSelected: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onDateSelected = onDateSelected
        
        let calendar = Calendar.current
        _year = State(initialValue: calendar.component(.year, from: initialDate))
        _month = State(initialValue: calendar.component(.month, from: initialDate))
        _day = State(initialValue: calendar.component(.day, from: initialDate))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Set Death Date")
                .font(.headline)
                .foregroundColor(.white)
            
            // Digital crown date picker
            HStack(spacing: 2) {
                // Month component
                DateComponentView(
                    value: $month,
                    range: 1...12,
                    isFocused: focusedField == .month,
                    formatter: { String(format: "%02d", $0) },
                    onTap: { 
                        focusedField = .month
                        crownValue = Double(month)
                    }
                )
                
                Text("/").foregroundColor(.gray)
                
                // Day component
                DateComponentView(
                    value: $day,
                    range: 1...daysInMonth(month: month, year: year),
                    isFocused: focusedField == .day,
                    formatter: { String(format: "%02d", $0) },
                    onTap: { 
                        focusedField = .day
                        crownValue = Double(day)
                    }
                )
                
                Text("/").foregroundColor(.gray)
                
                // Year component
                DateComponentView(
                    value: $year,
                    range: 2023...2120,
                    isFocused: focusedField == .year,
                    formatter: { String($0) },
                    onTap: { 
                        focusedField = .year
                        crownValue = Double(year)
                    }
                )
            }
            .focusable()
            .digitalCrownRotation($crownValue.animation(), 
                from: minValueForFocusedField(),
                through: maxValueForFocusedField(),
                by: 1.0,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { oldValue, newValue in
                updateFocusedField(with: Int(newValue.rounded()))
            }
            
            Button("Set Date") {
                let components = DateComponents(
                    year: year,
                    month: month,
                    day: day,
                    hour: 18, // Keep the default time at 6 PM
                    minute: 0
                )
                if let date = Calendar.current.date(from: components) {
                    onDateSelected(date)
                    dismiss()
                }
            }
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.primary)
        }
        .padding()
    }
    
    // Helper methods for Digital Crown rotation
    private func minValueForFocusedField() -> Double {
        switch focusedField {
        case .month: return 1.0
        case .day: return 1.0
        case .year: return 2023.0
        }
    }
    
    private func maxValueForFocusedField() -> Double {
        switch focusedField {
        case .month: return 12.0
        case .day: return Double(daysInMonth(month: month, year: year))
        case .year: return 2120.0
        }
    }
    
    private func updateFocusedField(with value: Int) {
        switch focusedField {
        case .month:
            month = min(max(1, value), 12)
            // Ensure the day is valid for the new month
            day = min(day, daysInMonth(month: month, year: year))
        case .day:
            day = min(max(1, value), daysInMonth(month: month, year: year))
        case .year:
            year = min(max(2023, value), 2120)
            // Ensure the day is valid for the new year (leap year handling)
            day = min(day, daysInMonth(month: month, year: year))
        }
    }
    
    // Helper to determine days in month considering leap years
    private func daysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        
        // Get the last day of the month
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // Fallback
    }
}

// Component for each date part (month, day, year)
struct DateComponentView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let isFocused: Bool
    let formatter: (Int) -> String
    let onTap: () -> Void
    
    var body: some View {
        Text(formatter(value))
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
            .frame(minWidth: isFocused ? 45 : 42)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isFocused ? Color.orange : Color.clear, lineWidth: 2)
            )
            .onTapGesture(perform: onTap)
    }
}
