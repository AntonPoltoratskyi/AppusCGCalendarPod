//
//  CalendarError.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

public enum CalendarError: Error, CustomStringConvertible {
    
    case initializingError(reason: String)
    case indexError(reason: String)
    
    public var description: String {
        switch self {
        case let .initializingError(reason):
            return "CalendarError: Initialize error reason: " + reason
        case let .indexError(reason):
            return "CalendarError: Index Error reason: " + reason
        }
    }
}
