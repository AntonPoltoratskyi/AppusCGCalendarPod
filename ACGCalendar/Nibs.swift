//
//  Utils.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

enum Nib: String {
    case calendarView = "CalendarView"
    case monthCollectionViewCell = "MonthCollectionViewCell"
    case monthTitleCollectionViewCell = "MonthTitleCollectionViewCell"
    case weekdaysCollectionViewCell = "WeekdaysCollectionViewCell"
    
    func create() -> UINib {
        return UINib(nibName: self.rawValue, bundle: AppBundle.shared.defaultBundle)
    }
}
