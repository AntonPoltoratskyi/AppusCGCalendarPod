//
//  Month.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

private typealias Position = (weekIndex: Int, dayIndex: Int)

public struct Month {
    
    static var firstWeekDay: WeekDay = .sunday
    
    fileprivate(set) var weeks: [[Day?]] = Array(repeating: Array(repeating: nil, count: CalendarUtils.daysInWeek),
                                                 count: CalendarUtils.maxWeekInMonth)
    
    fileprivate(set) var firstDayIndex: Int = 0
    fileprivate(set) var weeksCount: Int = CalendarUtils.maxWeekInMonth
    
    fileprivate(set) var previousDaysCount: Int!     // Count of 'inout' days from previous month related to current month
    fileprivate(set) var nextDaysCount: Int!         // Count of 'inout' days from next month related to current month
    
    public var isFullPreviousInoutWeek: Bool {
        return previousDaysCount >= CalendarUtils.daysInWeek
    }
    
    public var isFullNextInoutWeek: Bool {
        return nextDaysCount >= CalendarUtils.daysInWeek
    }
    
    public var currentDate: DateItem? {
        didSet {
            if let currentDate = currentDate {
                updateCurrentDate(currentDate)
            }
        }
    }
    
    public fileprivate(set) var monthDate: MonthDate
    public var year: Int {
        return monthDate.year
    }
    /// Value from 1 to 12
    public var month: Int {
        return monthDate.month
    }
    
    
    // MARK: - Init
    
    public init(year: Int, month: Int) {
        self.monthDate = MonthDate(year: year, month: month)
        setupDays(for: self.monthDate)
    }
    
    
    // MARK: - Selection
    
    mutating func selectDay(_ day: Day) {
        var selectedDay = day
        selectedDay.isSelected = true
        
        if let position = self.position(of: day) {
            weeks[position.weekIndex][position.dayIndex] = selectedDay
        }
    }
    
    mutating func unselectDay(_ day: Day) {
        var selectedDay = day
        selectedDay.isSelected = false
        
        if let position = self.position(of: day) {
            weeks[position.weekIndex][position.dayIndex] = selectedDay
        }
    }
    
    /// Deselect all selected days if have more than 1 selected day.
    mutating func resetSelection() {
        
        for (weekIndex, week) in self.weeks.enumerated() {
            for (dayIndex, day) in week.enumerated() {
                
                guard var day = day, day.isSelected else {
                    continue
                }
                day.isSelected = false
                weeks[weekIndex][dayIndex] = day
            }
        }
    }
    
    
    // MARK: - Private
    
    // MARK: Data Setup
    
    private mutating func setupDays(for monthDate: MonthDate) {
        
        let firstWeekdayIndex = self.firstWeekdayIndex(for: monthDate)
        self.firstDayIndex = firstWeekdayIndex
        
        // Setup inout days from previous month
        let previousInoutDaysCount = firstWeekdayIndex
        setupPreviousInoutDays(for: monthDate, inoutDaysCount: previousInoutDaysCount)
        
        // Setup days of current month
        var weekIndex = 0
        var dayIndex = firstWeekdayIndex
        
        for i in 1...CalendarUtils.daysCount(for: monthDate) {
            
            let weekday = WeekDay(with: dayIndex, considering: Month.firstWeekDay)
            let dateItem = DateItem(year: year, month: month, day: i)
            
            var day = Day(with: dateItem,
                          weekday: weekday,
                          type: .current)
            
            if let currentDate = self.currentDate {
                day.isToday = currentDate.day == day.dateItem.day
            }
            weeks[weekIndex][dayIndex] = day
            
            if (dayIndex == CalendarUtils.daysInWeek - 1) {
                weekIndex += 1
                dayIndex = 0
            } else {
                dayIndex += 1
            }
        }
        
        // Check if last date of month is last day of week
        self.weeksCount = dayIndex != 0
            ? weekIndex + 1
            : weekIndex
  
        // Setup inout days from next month
        setupNextInoutDays(for: monthDate, startIndex: dayIndex, toWeekAt: weekIndex)
    }
    
    private func firstWeekdayIndex(for monthDate: MonthDate) -> Int {
        
        let firstDayDate = CalendarUtils.dateFrom(year: monthDate.year, month: monthDate.month)!
        let dayOfWeek = CalendarUtils.dayOfWeek(for: firstDayDate)! - 1
        
        var result = dayOfWeek - Month.firstWeekDay.index
        if result < 0 {
            result = CalendarUtils.daysInWeek + result
        }
        return result
    }
    
    private mutating func setupPreviousInoutDays(for monthDate: MonthDate, inoutDaysCount: Int) {
        self.previousDaysCount = inoutDaysCount
        
        guard inoutDaysCount > 0 else { return }
        
        let previousMonth = CalendarUtils.previousMonth(for: monthDate)
        let previousMonthDaysCount = CalendarUtils.daysCount(for: previousMonth)
        
        let weekIndex = 0
        
        for (dayIdx, inoutDayNumber) in (previousMonthDaysCount-inoutDaysCount + 1...previousMonthDaysCount).enumerated() {
            
            let weekday = WeekDay(with: dayIdx, considering: Month.firstWeekDay)
            let dateItem = DateItem(year: previousMonth.year, month: previousMonth.month, day: inoutDayNumber)
            
            var day = Day(with: dateItem,
                          weekday: weekday,
                          type: .inout)
            
            if let currentDate = self.currentDate {
                day.isToday = currentDate.day == day.dateItem.day
            }
            weeks[weekIndex][dayIdx] = day
        }
    }
    
    private mutating func setupNextInoutDays(for monthDate: MonthDate, startIndex startDayIndex: Int, toWeekAt startWeekIndex: Int) {
        
        var inoutDaysCount = CalendarUtils.daysInWeek - startDayIndex
        if startWeekIndex != CalendarUtils.maxWeekInMonth - 1 {
            inoutDaysCount += CalendarUtils.daysInWeek
        }
        self.nextDaysCount = inoutDaysCount
        
        let nextMonth = CalendarUtils.nextMonth(for: monthDate)
        
        var dayIdx = startDayIndex
        var weekIndex = startWeekIndex
        
        for inoutDayNumber in 1...inoutDaysCount {
            
            let weekday = WeekDay(with: dayIdx, considering: Month.firstWeekDay)
            let dateItem = DateItem(year: nextMonth.year, month: nextMonth.month, day: inoutDayNumber)
            
            var day = Day(with: dateItem,
                          weekday: weekday,
                          type: .inout)
            
            if let currentDate = self.currentDate {
                day.isToday = currentDate.day == day.dateItem.day
            }
            weeks[weekIndex][dayIdx] = day
            
            if (dayIdx == CalendarUtils.daysInWeek - 1) {
                weekIndex += 1
                dayIdx = 0
            } else {
                dayIdx += 1
            }
        }
    }
    
    // MARK: Current Date
    
    private mutating func updateCurrentDate(_ dateItem: DateItem) {
        
        guard dateItem.month == self.month else {
            return
        }
        let weekIndex = week(for: dateItem)
        let weekDays = weeks[weekIndex]
        
        var currentDay: Day?
        var dayIndex = -1
        
        for (index, day) in weekDays.enumerated() {
            if day?.dateItem == dateItem {
                currentDay = day
                dayIndex = index
                break
            }
        }
        if var currentDay = currentDay {
            currentDay.isToday = true
            weeks[weekIndex][dayIndex] = currentDay
        }
    }
    
    // MARK: Utils
    
    private func week(for dateItem: DateItem) -> Int {
        return (self.firstDayIndex + dateItem.day - 1) / CalendarUtils.daysInWeek
    }
    
    private func position(of day: Day) -> Position? {
        
        var weekIdx = -1
        var dayIdx = -1
        
        switch day.dateItem.month {
        case self.month:
            weekIdx = (self.firstDayIndex + day.dateItem.day - 1) / CalendarUtils.daysInWeek
            dayIdx = (self.firstDayIndex + day.dateItem.day - 1) % CalendarUtils.daysInWeek
            
        case CalendarUtils.previousMonth(for: self.monthDate).month:
            weekIdx = 0
            for (index, dayModel) in weeks[weekIdx].enumerated() {
                if dayModel?.dateItem == day.dateItem {
                    dayIdx = index
                }
            }
        case CalendarUtils.nextMonth(for: self.monthDate).month:
            
            for weekIdx in weeksCount - 1..<weeks.count {
                let week = weeks[weekIdx]
                for (index, dayModel) in week.enumerated() {
                    if dayModel?.dateItem == day.dateItem {
                        dayIdx = index
                    }
                }
            }
        default:
            break
        }
        return weekIdx >= 0 && dayIdx >= 0 ? (weekIndex: weekIdx, dayIndex: dayIdx) : nil
    }
}


// MARK: - Current Month
public extension Month {
    
    public static var current: Month {
        let curentDateItem = DateItem.current
        return Month(year: curentDateItem.year, month: curentDateItem.month)
    }
}

