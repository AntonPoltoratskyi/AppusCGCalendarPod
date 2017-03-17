//
//  CalendarViewController.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/2/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

/*
 * Demo controller
 */
class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var calendarViewBottomConstraint: NSLayoutConstraint!
    
    var calendarSettings: CalendarSettings!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        calendarView.reloadCalendar()
    }
    
    
    // MARK: - Setup
    
    func setupCalendar() {
        
        calendarSettings = DefaultCalendarSettings()
        
        calendarSettings.firstWeekDay = .monday
        
        calendarSettings.allowsMultipleSelection = true
        calendarSettings.shouldAutoresizeHeight = true
        calendarSettings.shouldScrollWeekdays = true
        calendarSettings.showInOutDays = true
        
        calendarSettings.contentInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        
        calendarSettings.borderStyle = [.currentDays]
        calendarSettings.borderDirection = [.horizontal]
        calendarSettings.borderWidth = 1
        calendarSettings.borderLineCapStyle = .round
        calendarSettings.showOutBorders = true
        
        calendarSettings.shouldShowEventsForInoutDays = true
        calendarSettings.alphaForInoutDays = 0.3
        
        calendarSettings.weekdaysTitleHeight = 30
        calendarSettings.monthTitleHeight = 40
        
        
        calendarView.scrollDirection = .horizontal
        calendarView.isSurroundingMonthTitlesVisible = true
        calendarView.titleHeaderLayout = LinearCalendarHeaderLayout()
        // calendarView.initialDate = DateItem(year: 2021, month: 1, day: 1)

        let selectedDays: [Day] = [
            Day(with: DateItem(year: 2017, month: 3, day: 17), weekday: .friday, type: .current),
            Day(with: DateItem(year: 2017, month: 3, day: 18), weekday: .saturday, type: .current),
            Day(with: DateItem(year: 2017, month: 3, day: 19), weekday: .sunday, type: .current),
            Day(with: DateItem(year: 2017, month: 4, day: 2), weekday: .sunday, type: .current)
        ]
        try? calendarView.setup(with: calendarSettings, selectedDays: selectedDays, delegate: self)
    }
    
}


// MARK: - CalendarDelegate
extension CalendarViewController: CalendarDelegate {
    
    func calendarView(_ calendarView: CalendarView, didSelectDay day: Day) {
        print("didSelectDay day: \(day)")
    }
    
    func calendarView(_ calendarView: CalendarView, didDeselectDay day: Day) {
        print("didDeselectDay day: \(day)")
    }
    
    func calendarView(_ calendarView: CalendarView, shouldSelectDay day: Day) -> Bool {
        return true
    }
    func calendarView(_ calendarView: CalendarView, shouldDeselectDay day: Day) -> Bool {
        return true
    }

    func calendarView(_ calendarView: CalendarView, boundingRectWillChange bounds: CGRect, changedHeight: CGFloat) {
        self.calendarViewBottomConstraint.constant = changedHeight
    }
    
    func calendarView(_ calendarView: CalendarView, dayAppearanceFor day: Day) -> DayAppearance? {
        
        if !day.isSelected && !day.isToday {
            let colors = [UIColor.white, UIColor.green, UIColor.blue]
            let shape: [DayAppearance.Shape] = [.rectangle, .circle, .roundedRect(corderRadius: 5)]
            let path: [DayAppearance.PathType] = [.fill, .stroke]
            
            let appearance = DayAppearance(textColor: colors[Int(arc4random_uniform(3))],
                                           textFont: calendarSettings.fontForDayLabel,
                                           backgroundColor: colors[Int(arc4random_uniform(3))],
                                           borderColor: colors[Int(arc4random_uniform(3))],
                                           borderWidth: 2,
                                           shape: shape[Int(arc4random_uniform(3))],
                                           pathType: path[Int(arc4random_uniform(2))],
                                           isDrawShapeOverlay: day.dateItem.day % 3 == 0,
                                           isDrawEvents: false)
            return appearance
        }
        return nil
    }
    
    func countOfEvents(for day: Day) -> Int {
        return Int(arc4random_uniform(5))
    }
}

