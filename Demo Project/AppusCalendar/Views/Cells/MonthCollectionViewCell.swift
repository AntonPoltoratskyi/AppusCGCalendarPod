//
//  MonthCollectionViewCell.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class MonthCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var monthView: MonthView!
    
    func setupWith(month: Month, calendarSettings: CalendarSettings, delegate: MonthViewDelegate? = nil, dataSource: MonthViewDataSource? = nil) {
        monthView.setupWith(month: month, calendarSettings: calendarSettings)
        monthView.delegate = delegate
        monthView.dataSource = dataSource
    }
}

extension MonthCollectionViewCell: ReusableView {
}
