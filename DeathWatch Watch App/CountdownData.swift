//
//  CountdownData.swift
//  DeathWatch
//
//  Created by Nathan Eagle on 2/24/25.
//


import Foundation
struct CountdownData {
    let targetDate: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, h:mm a"
        return formatter.string(from: targetDate)
    }
    
    var hoursRemaining: Int {
        let difference = targetDate.timeIntervalSinceNow
        return max(0, Int(difference / 3600))
    }
    
    static func create() -> CountdownData {
        let savedDate = UserDefaults.standard.object(forKey: "targetDate") as? Date
        
        if let date = savedDate {
            return CountdownData(targetDate: date)
        } else {
            // Fall back to default date if none is saved
            var dateComponents = DateComponents()
            dateComponents.year = 2056
            dateComponents.month = 12
            dateComponents.day = 21
            dateComponents.hour = 18 // 6 PM
            dateComponents.minute = 0
            
            let calendar = Calendar.current
            let targetDate = calendar.date(from: dateComponents)!
            
            return CountdownData(targetDate: targetDate)
        }
    }
}
