//
//  MonthDate.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/6/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

public struct MonthDate {
    public var year: Int
    public var month: Int
}

extension MonthDate: Equatable {
    public static func ==(lhs: MonthDate, rhs: MonthDate) -> Bool {
        return lhs.year == rhs.year && lhs.month == lhs.month
    }
}
