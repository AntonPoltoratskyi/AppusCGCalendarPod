//
//  WeekdaysView.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/13/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class WeekdaysView: UIView {
    
    var calendarSettings: CalendarSettings? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let settings = calendarSettings else {
            return
        }
        
        if let weekdaysBackgroundColor = settings.weekdaysBackgroundColor {
            
            // Draw it on same height and y position as weekdays labels, but with full width.
            
            let backgroundPath = UIBezierPath(rect: rect)
            weekdaysBackgroundColor.setFill()
            backgroundPath.fill()
        }
        
        // Considering left and right content insets of calendar
        let borderInset = settings.isDrawBorders ? settings.borderWidth / 2 : 0
        let contentRect = CGRect(x: rect.origin.x + settings.contentInsets.left + borderInset,
                                 y: rect.origin.y,
                                 width: rect.size.width - settings.contentInsets.left - settings.contentInsets.right - borderInset * 2,
                                 height: rect.size.height)
        
        self.drawWeekdays(in: contentRect)
    }
    
    private func drawWeekdays(in rect: CGRect) {
        guard let settings = calendarSettings else { return }
        
        let x = rect.origin.x
        let y = rect.origin.y
        
        let dayWidth = rect.width / CGFloat(CalendarUtils.daysInWeek)
        let dayHeight = settings.weekdaysTitleHeight
        
        let foregroundColor = settings.fontColorForDayTitle
        let weekendForegroundColor = settings.fontColorForWeekendTitle ?? foregroundColor
        let weekdayFont = settings.fontForWeekdayLabel
        
        let borderInset = settings.isDrawBorders ? settings.borderWidth / 2 : 0
        
        for weekIndex in 0..<CalendarUtils.daysInWeek {
            
            let weekday = WeekDay(with: weekIndex, considering: Month.firstWeekDay)
            
            var color = foregroundColor
            if weekday.isWeekend {
                color = weekendForegroundColor
            }
            
            let text = CalendarUtils.string(from: weekday, dateFormat: settings.weekdaysTitleFormat)
            
            let weekdayRect = CGRect(x: x + dayWidth * CGFloat(weekIndex) + borderInset,
                                     y: y,
                                     width: dayWidth - borderInset * 2,
                                     height: dayHeight)
            self.drawWeekday(text, in: weekdayRect, color: color, font: weekdayFont)
        }
    }
    
    private func drawWeekday(_ weekdayName: String, in rect: CGRect, color: UIColor, font: UIFont) {
        
        let textHeight = rect.height
        
        let fontHeight = textHeight / 2
        let scaledFont = UIFont(name: font.fontName, size: fontHeight)!
        
        let yOffset = (rect.height - fontHeight) / 2
        let textRect = CGRect(x: rect.origin.x,
                              y: rect.origin.y + yOffset,
                              width: rect.width,
                              height: rect.height - yOffset)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let text = weekdayName as NSString
        text.draw(in: textRect,
                  withAttributes: [NSFontAttributeName: scaledFont,
                                   NSParagraphStyleAttributeName: paragraphStyle,
                                   NSForegroundColorAttributeName: color])
    }
}
