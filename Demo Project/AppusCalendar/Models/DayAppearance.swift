//
//  DayAppearance.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/16/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

/// Use it in CalendarDelegate func calendarView(_ calendarView: CalendarView, dayAppearanceFor day: Day) -> DayAppearance? implementation
/// in order to customize one separate day of month.
public struct DayAppearance {
    
    public enum Shape {
        case rectangle, circle, roundedRect(corderRadius: CGFloat)
    }
    public enum PathType {
        case fill, stroke
    }
    
    public var textColor: UIColor
    public var textFont: UIFont
    
    public var backgroundColor: UIColor
    public var borderColor: UIColor?
    public var borderWidth: CGFloat
    
    public var shape: Shape
    public var pathType: PathType
    
    // 'true' if should draw circle or rectangle for day
    public var isDrawShapeOverlay: Bool
    public var isDrawEvents: Bool
    
    public var eventPointRadius: CGFloat?
    
    public init(textColor: UIColor,
                textFont: UIFont,
                backgroundColor: UIColor,
                borderColor: UIColor,
                borderWidth: CGFloat = 1.0,
                shape: Shape = .circle,
                pathType: PathType = .fill,
                isDrawShapeOverlay: Bool = false,
                isDrawEvents: Bool = true,
                eventPointRadius: CGFloat? = nil) {
        
        self.textColor = textColor
        self.textFont = textFont
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shape = shape
        self.pathType = pathType
        self.isDrawShapeOverlay = isDrawShapeOverlay
        self.isDrawEvents = isDrawEvents
        self.eventPointRadius = eventPointRadius
    }
}
