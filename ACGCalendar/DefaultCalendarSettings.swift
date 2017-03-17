//
//  CalendarSettings.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

open class DefaultCalendarSettings: CalendarSettings {
    
    open var initialDate = Date()
    open var pagingMonthCount = 60              // preload 5 years in both directions
    
    open var firstWeekDay: WeekDay = .sunday
    open var locale: Locale? = Locale.current
    
    open var allowsMultipleSelection: Bool = false
    open var shouldAutoresizeHeight: Bool = false
    open var shouldScrollWeekdays: Bool = true
    open var showInOutDays = true
    
    
    // MARK: - Date Format
    
    open var monthTitleFormat: String = "LLLL YYYY"
    open var weekdaysTitleFormat: String = "EE"
    
    
    // MARK: - Size / Insets
    
    open var monthTitleHeight: CGFloat = 35
    open var weekdaysTitleHeight: CGFloat = 35
    
    open var contentInsets: UIEdgeInsets  = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    
    // MARK: - Border
    
    open var borderStyle: CalendarBorderStyle = [.none]
    open var borderDirection: CalendarBorderDirection = [.horizontal, .vertical]
    
    open var showOutBorders: Bool = true
    open var borderWidth: CGFloat = 1
    
    open var borderLineCapStyle: CGLineCap = .butt
    open var borderLineJoinStyle: CGLineJoin = .miter
    
    // MARK: - Events
    
    open var eventPointRadius: CGFloat = 2
    open var shouldShowEventsForInoutDays: Bool = true
    
    
    // MARK: - Colors
    
    open var backgroundColor: UIColor = UIColor.darkGray
    open var weekdaysBackgroundColor: UIColor? = UIColor.lightGray
    
    open var daysBorderColor: UIColor? = UIColor.lightGray
    
    open var colorForCommonDay: UIColor = UIColor.white
    open var colorForSelectedDay: UIColor = UIColor.blue
    open var colorForCurrentDay: UIColor = UIColor.yellow
    
    open var fontColorForCommonDay: UIColor = UIColor.white
    open var fontColorForSelectedDay: UIColor = UIColor.white
    open var fontColorForCurrentDay: UIColor = UIColor.black
    
    open var fontColorForInoutDay: UIColor? = UIColor.lightGray
    open var alphaForInoutDays: CGFloat?
    
    open var fontColorForWeekendDay: UIColor? = UIColor.green
    open var fontColorForWeekendTitle: UIColor? = UIColor.red
    
    open var fontColorForMonthTitle: UIColor = UIColor.white
    open var fontColorForDayTitle: UIColor = UIColor.white
    
    open func color(for countOfEvents: Int) -> UIColor {
        switch countOfEvents {
        case 0:
            return UIColor.white
        case 1:
            return UIColor.green
        case 2:
            return UIColor.yellow
        case 3:
            return UIColor.orange
        default:
            return UIColor.red
        }
    }
    
    // MARK: - Fonts
    
    open var fontForDayLabel: UIFont = UIFont (name: "HelveticaNeue", size: 16)!
    open var fontForMonthTitle: UIFont = UIFont (name: "HelveticaNeue", size: 18)!
    open var fontForWeekdayLabel: UIFont = UIFont (name: "HelveticaNeue", size: 16)!
    
}
