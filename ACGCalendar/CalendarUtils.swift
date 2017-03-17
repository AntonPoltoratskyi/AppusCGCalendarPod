//
//  CalendarUtils.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

class CalendarUtils {
    
    static let monthsInYear = 12
    static let daysInWeek = 7
    
    static let minWeekInMonth = 4
    static let maxWeekInMonth = 6
    
    static let minDaysInMonth = 28
    static let maxDaysInMonth = 31
    
    static fileprivate(set) var calendar: Calendar = {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    static var locale: Locale? {
        didSet {
            calendar.locale = locale
        }
    }
    private static let dateFormatter = DateFormatter()
    
    
    static func daysCount(for monthDate: MonthDate) -> Int {
        return count(of: .day, in: .month, for: monthDate)
    }
    
    private static func count(of smaller: Calendar.Component, in larger: Calendar.Component, for monthDate: MonthDate) -> Int {
        
        var dateComponents = DateComponents()
        dateComponents.year = monthDate.year
        dateComponents.month = monthDate.month
        
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: smaller, in: larger, for: date)
        
        let daysCount = range!.count
        return daysCount
    }
    
    static func previousMonth(for monthDate: MonthDate) -> MonthDate {
        var year = monthDate.year
        var month = monthDate.month - 1
        
        if month < 1{
            month = CalendarUtils.monthsInYear
            year -= 1
        }
        return MonthDate(year: year, month: month)
    }
    
    static func nextMonth(for monthDate: MonthDate) -> MonthDate {
        var year = monthDate.year
        var month = monthDate.month + 1
        
        if month > CalendarUtils.monthsInYear {
            month = 1
            year += 1
        }
        return MonthDate(year: year, month: month)
    }
    
    static func dateFrom(dateItem: DateItem) -> Date? {
        return self.dateFrom(year: dateItem.year, month: dateItem.month, day: dateItem.day)
    }
    
    static func dateFrom(year: Int, month: Int, day: Int = 1) -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        return calendar.date(from: dateComponents)
    }
    
    static func dateItemFrom(date: Date) -> DateItem {
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return DateItem(year: year, month: month, day: day)
    }
    
    static func dayOfWeek(for date: Date) -> Int? {
        let components = calendar.component(Calendar.Component.weekday, from: date)
        let weekDay = components
        return weekDay
    }
    
    static func string(from weekday: WeekDay, dateFormat: String) -> String {
        
        let weekdayDate = calendar.date(bySetting: .weekday, value: weekday.index + 1, of: Date())!
        
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: weekdayDate)
    }
    
    static func string(from monthDate: MonthDate, dateFormat: String) -> String {
        
        let firstMonthDate = CalendarUtils.dateFrom(year: monthDate.year, month: monthDate.month)!
        
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: firstMonthDate)
    }
}
