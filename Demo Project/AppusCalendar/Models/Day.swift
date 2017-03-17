//
//  Day.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

public enum DayType {
    /// Day from current displaying month
    case current
    /// Day from previous or next month, but displaying now
    case `inout`
}

public struct Day {
    
    public let dateItem: DateItem
    public let weekDay: WeekDay
    public let type: DayType
    
    public var isToday: Bool = false
    public var isSelected: Bool = false
    
    public var monthDate: MonthDate {
        return MonthDate(year: self.dateItem.year, month: self.dateItem.month)
    }
    
    /// Using for drawing day label on MonthView
    var formattedStringValue: String {
        return "\(dateItem.day)"
    }
    
    init(with dateItem: DateItem, weekday: WeekDay, type: DayType = .current) {
        self.dateItem = dateItem
        self.weekDay = weekday
        self.type = type
    }
}

extension Day: CustomStringConvertible {
    public var description: String {
        return "(dateItem:'\(dateItem.description)', weekday=\(weekDay), type=\(type), isToday=\(isToday), isSelected=\(isSelected)"
    }
}
