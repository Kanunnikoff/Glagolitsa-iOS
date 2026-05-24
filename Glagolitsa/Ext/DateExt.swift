//
//  DateExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 28.04.2025.
//

import Foundation

extension Date {
    
    func format(
        pattern: String = "yyyy-MM-dd",
        _ isOldRusMonthNames: Bool = false
    ) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(pattern)
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
        
        return if isOldRusMonthNames {
            formatter.formatOldRus(date: self)
        } else {
            formatter.string(from: self)
        }
    }
    
    func prettyFormat(
        _ isOldRusMonthNames: Bool = false
    ) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day], from: self)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let week = components.weekOfYear ?? 0
        let day = components.day ?? 0
        
        let thisComponents = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day], from: Date.now)
        let thisYear = thisComponents.year ?? 0
        let thisMonth = thisComponents.month ?? 0
        let thisWeek = thisComponents.weekOfYear ?? 0
        let thisDay = thisComponents.day ?? 0
        
        return if year == thisYear {
            if month == thisMonth {
                if week == thisWeek {
                    switch thisDay - day {
                        case 0: "сегодня, \(format(pattern: "H:mm", isOldRusMonthNames))"
                        case 1: "вчера, \(format(pattern: "H:mm", isOldRusMonthNames))"
                        case 2: "позавчера, \(format(pattern: "H:mm", isOldRusMonthNames))"
                        default: format(pattern: "EEEE, H:mm", isOldRusMonthNames)
                    }
                } else {
                    format(pattern: "d LLLL, H:mm", isOldRusMonthNames)
                }
            } else {
                format(pattern: "d LLLL, H:mm", isOldRusMonthNames)
            }
        } else {
            format(pattern: "d LLLL yyyy, H:mm", isOldRusMonthNames)
        }
    }
}
