//
//  CalendarDataSourceManager.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/6/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class InfiniteDataSourceManager: InfiniteDataSource {
    
    fileprivate(set) var queueSize: Int = 0
    
    fileprivate(set) var dataSource: [Int: [Int: Month]] = [:]
    fileprivate(set) var dateBatch: [MonthDate] = []
    
    var initialDate: DateItem?
    var currentDate: DateItem
    
    fileprivate(set) var selectedDays: [Day] = []
    fileprivate var initialSelectedDays: [Int: [Int: [Day]]] = [:]
    
    var lastSelectedDay: Day? {
        return selectedDays.last
    }
    
    var queue = DispatchQueue.global(qos: .userInteractive)
    
    
    // MARK: - Init
    
    required init(with initialDate: DateItem? = nil, selectedDays: [Day], queueSize: Int) {
        self.initialDate = initialDate
        self.currentDate = DateItem.current
        self.queueSize = queueSize
    
        for day in selectedDays {
            let year = day.dateItem.year
            let month = day.dateItem.month
            if initialSelectedDays[year] == nil {
                initialSelectedDays[year] = [:]
            }
            if initialSelectedDays[year]?[month] == nil {
               initialSelectedDays[year]?[month] = []
            }
            initialSelectedDays[year]?[month]?.append(day)
        }
    
        do {
            try reset(to: initialDate)
        } catch {
            debugPrint(error)
        }
    }
    
    
    // MARK: - Reload
    
    private func setupDataSource() {
        
        guard let initialDate = self.initialDate else { return }
    
        let half = self.queueSize / 2
        
        let beforeItemsCount = self.queueSize % 2 == 0 ? half - 1 : half
        let afterItemsCount = half
        
        let currentMonthDate = MonthDate(year: self.currentDate.year, month: self.currentDate.month)
        let initialMonthDate = MonthDate(year: initialDate.year, month: initialDate.month)
       
        
        // Load previous from initial month
        self.loadMonths(date: initialMonthDate, count: beforeItemsCount, ascending: false)
        
        // Add initial month
        if self.month(for: initialMonthDate) == nil {
            var initialMonth = Month(year: initialDate.year, month: initialDate.month)
            
            self.initialSelectedDays[initialMonthDate.year]?[initialMonthDate.month]?.forEach { day in
                initialMonth.selectDay(day)
            }
            if initialMonthDate == currentMonthDate {
                initialMonth.currentDate = currentDate
            }
            self.setMonth(initialMonth, for: initialMonthDate)
            self.dateBatch.append(initialMonthDate)
        }
        
        // Load next from initial month
        self.loadMonths(date: initialMonthDate, count: afterItemsCount, ascending: true)
    }
    
    
    // MARK: - Current Visible Data
    
    func countOfRows(for visibleItemsCount: Int, pagingItemsCount: Int, page: Int) throws -> Int {
        guard page < visibleItemsCount + pagingItemsCount * 2 else {
            throw CalendarError.indexError(reason: "page beyond bounds")
        }
        
        let visibleMonths = try self.visibleMonths(for: visibleItemsCount, pagingItemsCount: pagingItemsCount, page: page)
        
        var allCountOfWeeks: [Int] = []
        visibleMonths.forEach { monthDate in
            let month = self.month(for: monthDate)
            allCountOfWeeks.append(month!.weeksCount)
        }
        return allCountOfWeeks.max()!
    }
    
    func visibleMonths(for visibleItemsCount: Int, pagingItemsCount: Int, page: Int) throws -> [MonthDate] {
        guard visibleItemsCount > 0 else {
            throw CalendarError.indexError(reason: "batch size must be greater than 0")
        }
        guard pagingItemsCount >= 0 else {
            throw CalendarError.indexError(reason: " count of items for paging must be greater or equal 0")
        }
        
        var monthDates = [MonthDate]()
        if page < 0 || page >= (visibleItemsCount + 2 * pagingItemsCount) / visibleItemsCount {
            return []
        }
        let startIdx = page * visibleItemsCount
        for i in startIdx..<startIdx + visibleItemsCount {
            monthDates.append(dateBatch[i])
        }
        return monthDates
    }
    
    
    // MARK: - Selection
    
    func select(day: Day) {
        
        let monthDate = day.monthDate
        
        if var month = self.month(for: monthDate) {
            var day = day
            day.isSelected = true
            
            month.selectDay(day)
            
            self.setMonth(month, for: month.monthDate)
            self.selectedDays.append(day)
        }
    }
    
    func deselect(day: Day) {
        
        let monthDate = day.monthDate
        
        if var selectedMonth = self.month(for: monthDate) {
            selectedMonth.unselectDay(day)
            
            self.setMonth(selectedMonth, for: monthDate)
            
            let deselectedIndex = self.selectedDays.index { $0.dateItem == day.dateItem }
            if let index = deselectedIndex {
                self.selectedDays.remove(at: index)
            }
        }
    }
    
    func deselectLast() {
        if let lastSelectedDay = self.lastSelectedDay {
            self.deselect(day: lastSelectedDay)
        }
    }
    
    
    // MARK: - Index Path
    
    func month(at indexPath: IndexPath) -> Month? {
        let monthDate = self.monthDate(at: indexPath.row)
        return self.month(for: monthDate)
    }
    
    
    // MARK: - Reset
    
    func reset(to initialDate: DateItem? = nil) throws {

        self.currentDate = DateItem.current
        
        if let dayItem = initialDate {
            guard dayItem.isValid else {
                throw CalendarError.initializingError(reason: " wrong initialDate")
            }
            self.initialDate = initialDate
        } else {
            self.initialDate = self.currentDate
        }
        dateBatch = []
        setupDataSource()
    }
    
    
    // MARK: - Pagination
    
    func loadNext(count: Int, completion: @escaping () -> ()) {
        self.queue.async {
            guard let lastDate = self.dateBatch.last else {
                completion()
                return
            }
            self.loadMonths(date: lastDate, count: count, ascending: true)
            self.dateBatch.replaceSubrange(0..<count, with: [])
            DispatchQueue.main.async {
                completion();
            }
        }
    }
    
    func loadPrevious(count: Int, completion: @escaping () -> ()) {
        self.queue.async {
            guard let firstDate = self.dateBatch.first else {
                completion()
                return
            }
            self.loadMonths(date: firstDate, count: count, ascending: false)
            self.dateBatch.replaceSubrange(self.dateBatch.count - count..<self.dateBatch.count, with: [])
            DispatchQueue.main.async {
                completion();
            }
        }
    }
    
    /*
     * if 'ascending' == true - load next months, otherwise - previous months.
     */
    private func loadMonths(date: MonthDate, count: Int, ascending: Bool) {
        let currentMonthDate = MonthDate(year: self.currentDate.year, month: self.currentDate.month)
        var lastDate = date
        
        let action = ascending ? CalendarUtils.nextMonth : CalendarUtils.previousMonth
        for _ in 0..<count {
            lastDate = action(lastDate)
            
            var month: Month
            if let exitingMonth = self.month(for: lastDate){
                month = exitingMonth
            } else {
                month = Month(year: lastDate.year, month: lastDate.month)
            }
            self.initialSelectedDays[lastDate.year]?[lastDate.month]?.forEach { day in
                month.selectDay(day)
            }
            if currentMonthDate == lastDate {
                month.currentDate = self.currentDate
            }
            self.setMonth(month, for: lastDate)
            
            if ascending || self.dateBatch.isEmpty {
                self.dateBatch.append(lastDate)
            } else {
                self.dateBatch.insert(lastDate, at: 0)
            }
        }
    }
    
    
    // MARK: - Private Utils
    
    private func monthDate(at index: Int) -> MonthDate {
        return self.dateBatch[index]
    }
    
    private func month(for monthDate: MonthDate) -> Month? {
        return self.dataSource[monthDate.year]?[monthDate.month]
    }
    
    private func setMonth(_ month: Month, for monthDate: MonthDate) {
        if self.dataSource[monthDate.year] == nil {
            self.dataSource[monthDate.year] = [:]
        }
        self.dataSource[monthDate.year]?[monthDate.month] = month
    }
}
