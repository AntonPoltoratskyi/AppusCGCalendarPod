//
//  DateItem.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

public struct DateItem {
    public var year: Int
    public var month: Int
    public var day: Int
}

// MARK: - Validation
public extension DateItem {
    public var isValid: Bool {
        return year >= 1970
            && 1...CalendarUtils.monthsInYear ~= month
            && 1...CalendarUtils.maxDaysInMonth ~= day
    }
}

// MARK: - Current Date
public extension DateItem {
    
    public static var current: DateItem {
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        return DateItem(year: components.year!, month: components.month!, day: components.day!)
    }
}

// MARK: - Equatable
extension DateItem: Equatable {
    public static func ==(lhs: DateItem, rhs: DateItem) -> Bool {
        return lhs.year == rhs.year
            && lhs.month == rhs.month
            && lhs.day == rhs.day
    }
}

// MARK: - CustomStringConvertible
extension DateItem: CustomStringConvertible {
    public var description: String {
        return "(year=\(year), month=\(month), day=\(day))"
    }
}
