//
//  CalendarDataSource.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/6/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

protocol InfiniteDataSource: class {
    
    // Summary count of months in 'dateBatch' array
    var queueSize: Int { get }
    
    var initialDate: DateItem? { get set }
    
    var selectedDays: [Day] { get }
    var lastSelectedDay: Day? { get }
    
    var dataSource: [Int: [Int: Month]] { get }
    var dateBatch: [MonthDate] { get }
    
    init(with initialDate: DateItem?, selectedDays: [Day], queueSize: Int)
    
    func countOfRows(for visibleItemsCount: Int, pagingItemsCount: Int, page: Int) throws -> Int
    func visibleMonths(for visibleItemsCount: Int, pagingItemsCount: Int, page: Int) throws -> [MonthDate]
    
    func reset(to initialDate: DateItem?) throws
    func loadNext(count: Int, completion: @escaping () -> ())
    func loadPrevious(count: Int, completion: @escaping () -> ())
    
    func select(day: Day)
    func deselect(day: Day)
    func deselectLast()
    
    func month(at indexPath: IndexPath) -> Month?
}
