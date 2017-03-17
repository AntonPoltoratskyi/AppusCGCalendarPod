//
//  MonthTitleCollectionViewCell.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/13/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class MonthTitleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var monthTitleLabel: UILabel!
    
    var calendarSettings: CalendarSettings?
    
    func setup(with month: Month, settings: CalendarSettings) {
        
        // TODO: maybe should add background color, which will be specific for title
        
        let text = CalendarUtils.string(from: month.monthDate, dateFormat: settings.monthTitleFormat)
        
        contentView.backgroundColor = settings.backgroundColor
        monthTitleLabel.textColor = settings.fontColorForMonthTitle
        monthTitleLabel.text = text
        monthTitleLabel.font = settings.fontForMonthTitle
    }
}

extension MonthTitleCollectionViewCell: ReusableView {
}
