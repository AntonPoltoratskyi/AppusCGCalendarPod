//
//  WeekDay.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

public enum WeekDay: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var index: Int {
        return self.rawValue - 1
    }
    public var isWeekend: Bool {
        return self == .saturday || self == .sunday
    }
    
    public init(with dayIdx: Int) {
        self.init(rawValue: dayIdx + 1)!
    }
    
    /*
     * Convenience initializer. See datasource creation in 'setupDays(for:)' in Month.swift
     */
    init(with index: Int, considering firstWeekDay: WeekDay) {
        var weekdayIdx = index + firstWeekDay.index
        if weekdayIdx >= CalendarUtils.daysInWeek {
            weekdayIdx = weekdayIdx - CalendarUtils.daysInWeek
        }
        self.init(with: weekdayIdx)
    }
}
