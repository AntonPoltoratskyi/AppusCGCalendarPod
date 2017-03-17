//
//  WeekdaysCollectionViewCell.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/13/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class WeekdaysCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var weekdaysView: WeekdaysView!
    
    var calendarSettings: CalendarSettings? {
        didSet {
            weekdaysView.calendarSettings = calendarSettings
        }
    }
    
    func setup(with settings: CalendarSettings) {
        calendarSettings = settings
    }
}

extension WeekdaysCollectionViewCell: ReusableView {
}
