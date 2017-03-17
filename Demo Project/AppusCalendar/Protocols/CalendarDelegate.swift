///
//  File.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

public protocol CalendarDelegate: class {
    
    func calendarView(_ calendarView: CalendarView, shouldSelectDay day: Day) -> Bool
    func calendarView(_ calendarView: CalendarView, shouldDeselectDay day: Day) -> Bool
    
    func calendarView(_ calendarView: CalendarView, didSelectDay day: Day)
    func calendarView(_ calendarView: CalendarView, didDeselectDay day: Day)

    /// You can customise appearance of separate days by return DayAppearance object.
    ///
    /// - Returns: Return 'nil', if want to use default calendar settings: 'CalendarSettings'
    func calendarView(_ calendarView: CalendarView, dayAppearanceFor day: Day) -> DayAppearance?
    
    /// Called when calendar bounds should change if 'calendarSettings.shouldAutoresizeHeight' set to 'true'
    ///
    /// - Parameters:
    ///   - calendarView: CalendarView
    ///   - bounds: bounds of CalendarView
    ///   - changedHeight: Height delta. Actually it is a height of week rows, which should not be displaying now
    /// if 'calendarSettings.shouldAutoresizeHeight' set to true
    func calendarView(_ calendarView: CalendarView, boundingRectWillChange bounds: CGRect, changedHeight: CGFloat)
    
    func countOfEvents(for day: Day) -> Int
}

public extension CalendarDelegate {

    func calendarView(_ calendarView: CalendarView, shouldSelectDay day: Day) -> Bool { return true }
    func calendarView(_ calendarView: CalendarView, shouldDeselectDay day: Day) -> Bool { return true }
    
    func calendarView(_ calendarView: CalendarView, didSelectDay day: Day) { }
    func calendarView(_ calendarView: CalendarView, didDeselectDay day: Day) { }
    
    func calendarView(_ calendarView: CalendarView, dayAppearanceFor day: Day) -> DayAppearance? { return nil }
    
    func calendarView(_ calendarView: CalendarView, boundingRectWillChange bounds: CGRect, changedHeight: CGFloat) { }
    
    func countOfEvents(for day: Day) -> Int { return 0 }
}
