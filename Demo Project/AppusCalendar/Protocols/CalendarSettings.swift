//
//  CalendarSettings.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/7/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

public struct CalendarBorderStyle: OptionSet {
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = CalendarBorderStyle(rawValue: 1 << 0)
    public static let currentDays = CalendarBorderStyle(rawValue: 1 << 1)
    public static let inOutDays = CalendarBorderStyle(rawValue: 1 << 2)
}

public struct CalendarBorderDirection: OptionSet {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let horizontal = CalendarBorderDirection(rawValue: 1 << 0)
    public static let vertical = CalendarBorderDirection(rawValue: 1 << 1)
}

/// CalendarView's settings. See protocol implementation in 'DefaultCalendarSettings'.
public protocol CalendarSettings {
    
    var initialDate: Date { get set }
    
    /// Count of months, which will preload in both directions from 'initialDate'. 60 months by default.
    var pagingMonthCount: Int { get set }
    
    /// First displaying day of week. Sunday by default.
    var firstWeekDay: WeekDay { get set }
    
    /// Locale, which will be used for drawing calendar title, weekdays. Current locale by default.
    var locale: Locale? { get set }
    
    /// Multi selection. 'false' by default.
    var allowsMultipleSelection: Bool { get set }
    
    /// 'false' by default. Set 'true' if need to resize height of CalendarView.
    /// Should also implement calendarView(_ calendarView: CalendarView, boundingRectWillChange bounds: CGRect, changedHeight: CGFloat) from CalendarDelegate
    var shouldAutoresizeHeight: Bool { get set }
    
    /// 'true' by default. Set 'true' if weekdays header should scroll with calendar month views.
    var shouldScrollWeekdays: Bool { get set }
    
    /// 'true' by default. Set 'true' if need to draw days from next and previous months
    var showInOutDays: Bool { get set }
    
    
    // MARK: - Date Format
    
    var monthTitleFormat: String { get set }
    var weekdaysTitleFormat: String { get set }
    
    
    // MARK: - Size / Insets
    
    var monthTitleHeight: CGFloat { get set }
    var weekdaysTitleHeight: CGFloat { get set }
    
    /// Content insets of view, which will draw month days
    var contentInsets: UIEdgeInsets { get set }
    
    
    // MARK: - Borders
    
    var borderStyle: CalendarBorderStyle { get set }
    var borderDirection: CalendarBorderDirection { get set }
    
    /// If 'false' - first and last horizontal and vertical borders won't draw on the screen
    var showOutBorders: Bool { get set }
    var borderWidth: CGFloat { get set }
    
    var borderLineCapStyle: CGLineCap { get set }
    var borderLineJoinStyle: CGLineJoin { get set }
    
    
    // MARK: - Events
    
    /// Radius of event point (dot) for each day in calendar
    var eventPointRadius: CGFloat { get set }
    
    /// Set 'false' if need to skip drawing of first and last vertical and horizontal border lines. 'true' by default
    var shouldShowEventsForInoutDays: Bool { get set }
    
    
    // MARK: - Colors
    
    var backgroundColor: UIColor { get set }
    var weekdaysBackgroundColor: UIColor? { get set }
    
    var colorForCommonDay: UIColor { get set }
    var colorForSelectedDay: UIColor { get set }
    var colorForCurrentDay: UIColor { get set }
    
    var fontColorForSelectedDay: UIColor { get set }
    var fontColorForCurrentDay: UIColor { get set }
    var fontColorForCommonDay: UIColor { get set }
    var fontColorForInoutDay: UIColor? { get set }
    var alphaForInoutDays: CGFloat?  { get set }
    
    var fontColorForWeekendDay: UIColor? { get set }
    var fontColorForWeekendTitle: UIColor? { get set }
    
    var fontColorForMonthTitle: UIColor { get set }
    var fontColorForDayTitle: UIColor { get set }
    
    var daysBorderColor: UIColor? { get set }
    
    func color(for countOfEvents: Int) -> UIColor
    
    
    // MARK: - Fonts
    
    var fontForDayLabel: UIFont { get set }
    var fontForMonthTitle: UIFont { get set }
    var fontForWeekdayLabel: UIFont { get set }
}

extension CalendarSettings {
    var visibleMonthCount: Int {
        return 1
    }
    var isDrawBorders: Bool {
        return borderStyle.contains(.currentDays) || borderStyle.contains(.inOutDays)
    }
}
