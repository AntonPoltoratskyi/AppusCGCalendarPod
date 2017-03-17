//
//  MonthView.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

private typealias Position = (x: Int, y: Int)

private let defaultBorderColor = UIColor.white

protocol MonthViewDelegate: class {
    func monthView(_ monthView: MonthView, didSelectDay day: Day)
    func monthView(_ monthView: MonthView, dayAppearanceFor day: Day) -> DayAppearance?
}
extension MonthViewDelegate {
    func monthView(_ monthView: MonthView, dayAppearanceFor day: Day) -> DayAppearance? {
        return nil
    }
}

protocol MonthViewDataSource: class {
    func monthView(_ monthView: MonthView, countOfEventsForDay day: Day) -> Int
}
extension MonthViewDataSource {
    func monthView(_ monthView: MonthView, countOfEventsForDay day: Day) -> Int {
        return 0
    }
}


class MonthView: UIView {
    
    weak var delegate: MonthViewDelegate?
    weak var dataSource: MonthViewDataSource?
    
    fileprivate var settings: CalendarSettings?
    fileprivate var month: Month?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestures()
    }
    
    func setupWith(month: Month, calendarSettings: CalendarSettings) {
        self.month = month
        self.settings = calendarSettings
        setNeedsDisplay()
    }
    
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let month = month, let settings = settings else {
            return
        }
        draw(month: month, with: settings, in: rect)
    }
    
    private func draw(month: Month, with settings: CalendarSettings, in rect: CGRect) {
        
        // Draw month border
        let isDrawBorders = settings.isDrawBorders
        let bordersInset: CGFloat = isDrawBorders ? settings.borderWidth / 2 : 0.0
        
        let contentRect = CGRect(x: rect.origin.x + settings.contentInsets.left + bordersInset,
                                 y: rect.origin.y + settings.contentInsets.top + bordersInset,
                                 width: rect.size.width - settings.contentInsets.left - settings.contentInsets.right - bordersInset * 2,
                                 height: rect.size.height - settings.contentInsets.top - settings.contentInsets.bottom - bordersInset * 2)
        
        // Draw borders
        
        if isDrawBorders {
            drawBorders(in: contentRect, month: month, settings: settings)
        }
        
        // Draw month days
        
        let dayWidth = contentRect.width / CGFloat(CalendarUtils.daysInWeek)
        let dayHeight = contentRect.height / CGFloat(CalendarUtils.maxWeekInMonth)
        
        for (weekIdx, week) in month.weeks.enumerated() {
            for (dayIdx, day) in week.enumerated() {
                
                guard !(settings.shouldAutoresizeHeight && month.isFullNextInoutWeek && weekIdx >= month.weeksCount) else {
                    break
                }
                guard let day = day else { continue }
                
                let position = (x: dayIdx, y: weekIdx)
                
                let dayRect = CGRect(x: xOffset(position.x, in: contentRect) + bordersInset,
                                     y: yOffset(position.y, in: contentRect) + bordersInset,
                                     width: dayWidth - bordersInset * 2,
                                     height: dayHeight - bordersInset * 2)
                
                if day.type == .current || settings.showInOutDays {
                    self.draw(day: day, with: settings, in: dayRect, at: position)
                }
            }
        }
        
    }
    
    
    // MARK: Borders
    
    private func drawBorders(in rect: CGRect, month: Month, settings: CalendarSettings) {
        
        let borderPath = UIBezierPath()
        
        if settings.borderDirection.contains(.vertical) {
            drawVerticalLines(in: rect, using: borderPath, month: month, calendarSettings: settings)
        }
        if settings.borderDirection.contains(.horizontal) {
            drawHorizontalLines(in: rect, using: borderPath, month: month, calendarSettings: settings)
        }
        
        (settings.daysBorderColor ?? defaultBorderColor).setStroke()
        
        borderPath.lineWidth = settings.borderWidth
        borderPath.lineCapStyle = settings.borderLineCapStyle
        borderPath.lineJoinStyle = settings.borderLineJoinStyle
        borderPath.stroke()
    }
    
    private func drawHorizontalLines(in contentRect: CGRect, using path: UIBezierPath, month: Month, calendarSettings: CalendarSettings) {
        
        // Draw first row line if needed
        if calendarSettings.showOutBorders {
            
            let firstPoint: CGPoint
            if !calendarSettings.borderStyle.contains(.inOutDays) {
                firstPoint = CGPoint(x: xOffset(month.firstDayIndex, in: contentRect),
                                     y: yOffset(0, in: contentRect))
            } else {
                firstPoint = CGPoint(x: xOffset(0, in: contentRect),
                                     y: yOffset(0, in: contentRect))
            }
            path.move(to: firstPoint)
            path.addLine(to: CGPoint(x: contentRect.topRight.x,
                                     y: contentRect.topRight.y))
        }
        
        let drawLine = { (weekIdx: Int) in
            let count = weekIdx != month.weeksCount || calendarSettings.borderStyle.contains(.inOutDays)
                ? CalendarUtils.daysInWeek
                : CalendarUtils.daysInWeek - month.nextDaysCount % CalendarUtils.daysInWeek
            
            path.move(to: CGPoint(x: self.xOffset(0, in: contentRect),
                                  y: self.yOffset(weekIdx, in: contentRect)))
            
            path.addLine(to: CGPoint(x: self.xOffset(count, in: contentRect),
                                     y: self.yOffset(weekIdx, in: contentRect)))
        }
        
        let hiddenBordersCount = !calendarSettings.showOutBorders ? 1 : 0
        
        for weekIdx in 1...month.weeksCount - hiddenBordersCount {
            drawLine(weekIdx)
        }
        
        if !calendarSettings.shouldAutoresizeHeight &&
            calendarSettings.borderStyle.contains(.inOutDays) &&
            month.weeksCount != CalendarUtils.maxWeekInMonth {
            
            for weekIdx in (month.weeksCount + 1 - hiddenBordersCount)...(CalendarUtils.maxWeekInMonth - hiddenBordersCount) {
                drawLine(weekIdx)
            }
        }
    }
    
    private func drawVerticalLines(in contentRect: CGRect, using path: UIBezierPath, month: Month, calendarSettings: CalendarSettings) {
        
        var firstRowIndex = 0
        if !calendarSettings.borderStyle.contains(.inOutDays) {
            firstRowIndex = 1
        }
        
        let drawLine = { (weekdayIdx: Int) in
            
            var yOffset = 0
            if weekdayIdx < month.firstDayIndex {
                yOffset = firstRowIndex
            }
            
            path.move(to: CGPoint(x: self.xOffset(weekdayIdx, in: contentRect),
                                  y: self.yOffset(yOffset, in: contentRect)))
            
            var bottomOffset = 0
            if !calendarSettings.borderStyle.contains(.inOutDays) {
                
                let inoutDaysAtLastCurrentMonthWeekRow = month.nextDaysCount % CalendarUtils.daysInWeek
                if weekdayIdx > CalendarUtils.daysInWeek - inoutDaysAtLastCurrentMonthWeekRow {
                    bottomOffset = 1
                }
            }
            if calendarSettings.shouldAutoresizeHeight || !calendarSettings.borderStyle.contains(.inOutDays) {
                path.addLine(to: CGPoint(x: self.xOffset(weekdayIdx, in: contentRect),
                                         y: self.yOffset(month.weeksCount - bottomOffset, in: contentRect)))
            } else {
                path.addLine(to: CGPoint(x: self.xOffset(weekdayIdx, in: contentRect),
                                         y: self.yOffset(CalendarUtils.maxWeekInMonth - bottomOffset, in: contentRect)))
            }
            
        }
        
        let hiddenBordersCount = !calendarSettings.showOutBorders ? 1 : 0
        
        for weekdayIdx in hiddenBordersCount...(CalendarUtils.daysInWeek - hiddenBordersCount) {
            drawLine(weekdayIdx)
        }
    }
    
    private func xOffset(_ dayIdx: Int, in contentRect: CGRect) -> CGFloat {
        
        let leftInset = contentRect.origin.x
        let dayWidth = contentRect.width / CGFloat(CalendarUtils.daysInWeek)
        
        return leftInset + CGFloat(dayIdx) * dayWidth
    }
    
    private func yOffset(_ weekIdx: Int, in contentRect: CGRect) -> CGFloat {
        
        let topInset = contentRect.origin.y
        let dayHeight = contentRect.height / CGFloat(CalendarUtils.maxWeekInMonth)
        
        return topInset + CGFloat(weekIdx) * dayHeight
    }
    
    
    // MARK: Day
    
    private func draw(day: Day, with settings: CalendarSettings, in dayRect: CGRect, at position: Position) {
        
        // Use delegate appearance or default appearance from CalendarSettings
        
        if let dayAppearance = delegate?.monthView(self, dayAppearanceFor: day) {
            drawDay(day, in: dayRect, appearance: dayAppearance, settings: settings)
        } else {
            drawDay(day, in: dayRect, settings: settings)
        }
    }
    
    
    func drawDay(_ day: Day, in dayRect: CGRect, appearance: DayAppearance, settings: CalendarSettings) {
        
        if appearance.isDrawShapeOverlay {
            
            drawOverlay(for: day,
                        in: dayRect,
                        backgroundColor: appearance.backgroundColor,
                        borderColor: appearance.borderColor,
                        borderWidth: appearance.borderWidth,
                        shape: appearance.shape,
                        pathType: appearance.pathType)
        }
        drawLabel(for: day, in: dayRect, color: appearance.textColor, font: settings.fontForDayLabel)
        
        if appearance.isDrawEvents {
            
            let eventsCount = self.dataSource?.monthView(self, countOfEventsForDay: day) ?? 0
            if eventsCount > 0 {
                let pointColor = settings.color(for: eventsCount)
                let alpha = day.type == .inout ? (settings.alphaForInoutDays ?? 1.0) : nil
                
                self.drawEventPoint(for: day, in: dayRect, color: pointColor, radius: appearance.eventPointRadius ?? settings.eventPointRadius, alpha: alpha)
            }
        }
    }
    
    func drawDay(_ day: Day, in dayRect: CGRect, settings: CalendarSettings) {
        
        var textColor = settings.fontColorForCommonDay
        if day.isToday {
            
            drawOverlay(for: day,
                        in: dayRect,
                        backgroundColor: settings.colorForCurrentDay,
                        borderColor: nil,
                        shape: .circle,
                        pathType: .fill)
            
            textColor = settings.fontColorForCurrentDay
        }
        if day.isSelected {
            
            drawOverlay(for: day,
                        in: dayRect,
                        backgroundColor: settings.colorForSelectedDay,
                        borderColor: nil,
                        shape: .circle,
                        pathType: .fill)
            
            textColor = settings.fontColorForSelectedDay
            
        } else if day.weekDay.isWeekend {
            if let weekendColor = settings.fontColorForWeekendDay {
                textColor = weekendColor
            }
        }
        
        if day.type == .inout {
            textColor = settings.fontColorForInoutDay ?? textColor
        }
        
        drawLabel(for: day, in: dayRect, color: textColor, font: settings.fontForDayLabel)
        
        if day.type != .inout || settings.shouldShowEventsForInoutDays {
            
            let eventsCount = self.dataSource?.monthView(self, countOfEventsForDay: day) ?? 0
            if eventsCount > 0 {
                let pointColor = settings.color(for: eventsCount)
                
                let alpha = day.type == .inout ? (settings.alphaForInoutDays ?? 1.0) : nil
                
                self.drawEventPoint(for: day, in: dayRect, color: pointColor, radius: settings.eventPointRadius, alpha: alpha)
            }
        }
    }
    
    
    // MARK: Text
    
    /*
     * Draw number of day in month.
     */
    private func drawLabel(for day: Day, in dayRect: CGRect, color: UIColor, font: UIFont) {
        
        // Content should be smaller than size of each 'day' bounds.
        let circleSize = self.circleSize(for: dayRect)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let fontHeight = min(font.lineHeight, circleSize.height / 2)
        let scaledFont = UIFont(name: font.fontName, size: fontHeight)!
        
        
        var circleRect = dayRect
        circleRect.origin.x += (dayRect.width - circleSize.width) / 2
        circleRect.origin.y += (dayRect.height - circleSize.height) / 2
        circleRect.size = circleSize
        
        let textRect = circleRect.insetBy(dx: 0, dy: (circleRect.height - scaledFont.lineHeight) / 2)
        
        let text = day.formattedStringValue as NSString
        
        text.draw(in: textRect,
                  withAttributes: [NSFontAttributeName: scaledFont,
                                   NSParagraphStyleAttributeName: paragraphStyle,
                                   NSForegroundColorAttributeName: color])
    }
    
    
    // MARK: Selection
    
    private func drawOverlay(for day: Day, in dayRect: CGRect, backgroundColor: UIColor, borderColor: UIColor?, borderWidth: CGFloat = 1, shape: DayAppearance.Shape, pathType: DayAppearance.PathType) {
        
        let circleSize = self.circleSize(for: dayRect)
        
        var circleRect = dayRect
        circleRect.origin.x += (dayRect.width - circleSize.width) / 2
        circleRect.origin.y += (dayRect.height - circleSize.height) / 2
        circleRect.size = circleSize
        
        
        let circlePath: UIBezierPath
        switch shape {
        case .rectangle:
            circlePath = UIBezierPath(rect: circleRect)
        case .circle:
            circlePath = UIBezierPath(ovalIn: circleRect)
        case .roundedRect(let cornerRadius):
            circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: cornerRadius)
        }
        
        
        switch pathType {
        case .fill:
            backgroundColor.setFill()
            circlePath.fill()
            
            if let borderColor = borderColor {
                borderColor.setStroke()
                circlePath.lineWidth = borderWidth
                circlePath.stroke()
            }
        case .stroke:
            backgroundColor.setStroke()
            circlePath.stroke()
        }
    }
    
    // MARK: Events
    
    private func drawEventPoint(for day: Day, in contentRect: CGRect, color: UIColor, radius: CGFloat, alpha: CGFloat?) {
        
        let circleSize = self.circleSize(for: contentRect)
        let yDotOffset = (contentRect.height - circleSize.height) / 2 + circleSize.height
        
        let eventContentRect = CGRect(x: contentRect.origin.x,
                                      y: contentRect.origin.y + yDotOffset,
                                      width: contentRect.width,
                                      height: contentRect.height - yDotOffset)
        
        let dotDiameter = radius * 2
        
        var eventPointRect = eventContentRect
        eventPointRect.origin.x += (eventContentRect.width - dotDiameter) / 2
        eventPointRect.origin.y += (eventContentRect.height - dotDiameter) / 2
        eventPointRect.size = CGSize(width: dotDiameter, height: dotDiameter)
        
        let eventPath = UIBezierPath(ovalIn: eventPointRect)
        color.setFill()
        eventPath.fill(with: .normal, alpha: alpha ?? 1.0)
    }
    
    // MARK: Utils
    
    private func circleSize(for contentRect: CGRect) -> CGSize {
        let maxSize = min(contentRect.width, contentRect.height) * 3 / 4
        return CGSize(width: maxSize, height: maxSize)
    }
}

// MARK: - Gestures
extension MonthView: UIGestureRecognizerDelegate {
    
    fileprivate func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionDayTapped(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc fileprivate func actionDayTapped(_ recognizer: UITapGestureRecognizer) {
        
        self.isUserInteractionEnabled = false
        defer {
            self.isUserInteractionEnabled = true
        }
        
        let tapPoint = recognizer.location(in: self)
        let dayWidth = self.frame.width / CGFloat(CalendarUtils.daysInWeek)
        let weekHeight = self.frame.height / CGFloat(CalendarUtils.maxWeekInMonth)
        
        let weekdayIndex = Int(tapPoint.x / dayWidth)
        let weekIndex = Int(tapPoint.y / weekHeight)
        
        guard weekdayIndex >= 0 && weekdayIndex < CalendarUtils.daysInWeek &&
            weekIndex >= 0 && weekIndex < CalendarUtils.maxWeekInMonth else {
                return
        }
        
        let selectedDay = self.month?.weeks[weekIndex][weekdayIndex]
        if let selectedDay = selectedDay {
            self.delegate?.monthView(self, didSelectDay: selectedDay)
        }
    }
}

// MARK: - CGRect Corners
private extension CGRect {
    var topLeft: CGPoint {
        return origin
    }
    var topRight: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y)
    }
    var bottomLeft: CGPoint {
        return CGPoint(x: origin.x, y: origin.y + size.height)
    }
    var bottomRight: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y + size.height)
    }
}
