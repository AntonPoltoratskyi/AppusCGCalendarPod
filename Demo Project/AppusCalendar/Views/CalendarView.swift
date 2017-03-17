//
//  CalendarView.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

public enum CalendarScrollDirection {
    case horizontal
    case vertical
}

enum TypeDispatcher <Wrapped> {
    case value(Wrapped)
    
    func dispatch<Subject>(f: (Subject) -> Void) -> TypeDispatcher<Wrapped> {
        switch self {
        case let .value(x):
            if let subject = x as? Subject {
                f(subject)
            }
            return .value(x)
        }
    }
    
    func extract() -> Wrapped {
        switch self {
        case let .value(x):
            return x
        }
    }
}

open class CalendarView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet public weak var monthTitlesCollectionView: UICollectionView!
    @IBOutlet public weak var weekdaysCollectionView: UICollectionView!
    @IBOutlet public weak var calendarCollectionView: CalendarCollectionView!
    
    @IBOutlet weak var titlesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weekdaysHeightConstraint: NSLayoutConstraint!
    
    
    public weak var calendarDelegate: CalendarDelegate?
    
    fileprivate(set) public var calendarSettings: CalendarSettings!
    
    fileprivate var calendarInfiniteDatasource: InfiniteDataSource? {
        didSet {
            reloadCalendar()
        }
    }
    
    public var titleHeaderLayout: UICollectionViewLayout? {
        didSet {
            if let layout = titleHeaderLayout {
                setupTitleHeaderLayout(layout)
                refreshTitleHeaderLayout(animated: false)
            }
        }
    }
    
    public var initialDate: DateItem = DateItem.current {
        didSet {
            guard calendarInfiniteDatasource != nil else { return }
            
            try? calendarInfiniteDatasource?.reset(to: initialDate)
            reloadCalendar()
        }
    }
    
    public var selectedDays: [Day]? {
        return calendarInfiniteDatasource?.selectedDays
    }
    
    public var scrollDirection: CalendarScrollDirection = .horizontal {
        didSet {
            setupCalendarScrollDirection(scrollDirection)
        }
    }
    
    /// Works only on horizontal scroll direction
    var isSurroundingMonthTitlesVisible: Bool = true
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        performInitialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        performInitialSetup()
    }
    
    
    // MARK: - Setup
    
    fileprivate func performInitialSetup() {
        
        let nib = Nib.calendarView.create()
        _ = nib.instantiate(withOwner: self, options: nil)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.showsHorizontalScrollIndicator = false
        
        monthTitlesCollectionView.delegate = self
        monthTitlesCollectionView.dataSource = self
        weekdaysCollectionView.delegate = self
        weekdaysCollectionView.dataSource = self
        
        monthTitlesCollectionView.isUserInteractionEnabled = false
        weekdaysCollectionView.isUserInteractionEnabled = false
        
        monthTitlesCollectionView.showsVerticalScrollIndicator = false
        monthTitlesCollectionView.showsHorizontalScrollIndicator = false
        weekdaysCollectionView.showsVerticalScrollIndicator = false
        weekdaysCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = self.titleHeaderLayout {
            setupTitleHeaderLayout(layout)
        }
        
        let monthCell = Nib.monthCollectionViewCell.create()
        calendarCollectionView.register(monthCell, forCellWithReuseIdentifier: MonthCollectionViewCell.reuseIdentifier)
        
        let titleCell = Nib.monthTitleCollectionViewCell.create()
        monthTitlesCollectionView.register(titleCell, forCellWithReuseIdentifier: MonthTitleCollectionViewCell.reuseIdentifier)
        
        let weekdaysCell = Nib.weekdaysCollectionViewCell.create()
        weekdaysCollectionView.register(weekdaysCell, forCellWithReuseIdentifier: WeekdaysCollectionViewCell.reuseIdentifier)
        
        setupCalendarScrollDirection(self.scrollDirection)
    }
    
    
    /// You should necessarily call this methos to setup calendar correctly.
    /// Can throw CalendarError.initializingError if 'selectedDays.count > 1' and 'settings.allowsMultipleSelection == false'.
    public func setup(with settings: CalendarSettings = DefaultCalendarSettings(), selectedDays: [Day] = [], delegate: CalendarDelegate? = nil) throws {
        
        guard selectedDays.count <= 1 || settings.allowsMultipleSelection else {
            throw CalendarError.initializingError(reason: "Try to setup more than 1 selected days with 'allowMultipleSelection' == false")
        }
        self.calendarDelegate = delegate
        
        setCalendarSettings(settings, selectedDays: selectedDays)
    }
    
    private func setCalendarSettings(_ settings: CalendarSettings, selectedDays: [Day]) {
        self.calendarSettings = settings
        
        CalendarUtils.locale = calendarSettings.locale
        Month.firstWeekDay = calendarSettings.firstWeekDay
        
        setupCalendarUI(with: calendarSettings)
        setupDataSource(with: calendarSettings, selectedDays: selectedDays)
        
        if calendarSettings.shouldAutoresizeHeight {
            self.setupFloatingHeightConstraint(with: calendarSettings)
        }
    }
    
    fileprivate func setupDataSource(with settings: CalendarSettings, selectedDays: [Day]) {
        
        let days = selectedDays.map { element -> Day in
            var day = element
            day.isSelected = true
            return day
        }
        self.calendarInfiniteDatasource = InfiniteDataSourceManager(with: self.initialDate,
                                                                    selectedDays: days,
                                                                    queueSize: settings.visibleMonthCount + settings.pagingMonthCount * 2)
    }
    
    fileprivate func setupTitleHeaderLayout(_ layout: UICollectionViewLayout) {
        
        let layoutScrollDirection: UICollectionViewScrollDirection = self.scrollDirection == .horizontal ? .horizontal : .vertical
        (layout as? UICollectionViewFlowLayout)?.scrollDirection = layoutScrollDirection
        
        monthTitlesCollectionView.collectionViewLayout = layout
    }
    
    fileprivate func setupCalendarScrollDirection(_ scrollDirection: CalendarScrollDirection) {
        switch scrollDirection {
        case .horizontal:
            (calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
            (monthTitlesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        case .vertical:
            (calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
            (monthTitlesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
        }
    }
    
    fileprivate func setupFloatingHeightConstraint(with settings: CalendarSettings) {
        
        let pageIndex: Int
        switch self.scrollDirection {
        case .horizontal:
            pageIndex = Int(calendarCollectionView.contentOffset.x / calendarCollectionView.frame.width)
        case .vertical:
            pageIndex = Int(calendarCollectionView.contentOffset.y / calendarCollectionView.frame.height)
        }
        do {
            let visibleWeeksCount = try calendarInfiniteDatasource!.countOfRows(for: settings.visibleMonthCount,
                                                                                pagingItemsCount: settings.pagingMonthCount,
                                                                                page: pageIndex)
            
            updateFloatingConstraint(newWeeksCount: visibleWeeksCount, currentWeeksCount: CalendarUtils.maxWeekInMonth, percentage: 1.0)
        } catch {
            debugPrint(error)
        }
    }
    
    fileprivate func setupCalendarUI(with settings: CalendarSettings) {
        
        [calendarCollectionView, monthTitlesCollectionView, weekdaysCollectionView].forEach {
            $0.backgroundColor = settings.backgroundColor
        }
        titlesHeightConstraint.constant = settings.monthTitleHeight
        weekdaysHeightConstraint.constant = settings.weekdaysTitleHeight
    }
    
    
    // MARK: - Reload
    
    public func reloadCalendar(animated: Bool = false) {
        reloadCollectionViews()
        
        let firstMonthIndexPath = IndexPath(item: calendarSettings.pagingMonthCount, section: 0)
        
        if firstMonthIndexPath.item < calendarInfiniteDatasource?.dateBatch.count ?? 0 {
            
            let scrollPosition: UICollectionViewScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            
            calendarCollectionView.scrollToItem(at: firstMonthIndexPath, at: scrollPosition, animated: animated)
            weekdaysCollectionView.scrollToItem(at: firstMonthIndexPath, at: scrollPosition, animated: animated)
            monthTitlesCollectionView.scrollToItem(at: firstMonthIndexPath, at: scrollPosition, animated: animated)
        }
    }
    
    public func reloadCollectionViews() {
        calendarCollectionView.reloadData()
        weekdaysCollectionView.reloadData()
        monthTitlesCollectionView.reloadData()
    }
    
    
    // MARK: - Title Header
    
    private func refreshTitleHeaderLayout(animated: Bool) {
        
        guard isCalendarSizeValid() else {
            return
        }
        let calendarOffset = calendarCollectionView.contentOffset
        
        let contentOffset: CGPoint
        switch self.scrollDirection {
        case .horizontal:
            contentOffset = horizontalHeaderBatchOffset(relatedTo: calendarOffset)
        case .vertical:
            contentOffset = verticalHeaderBatchOffset(relatedTo: calendarOffset)
        }
        monthTitlesCollectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    fileprivate func horizontalHeaderBatchOffset(relatedTo contentOffset: CGPoint) -> CGPoint {
        
        let scrollPercentage: CGFloat = contentOffset.x / calendarCollectionView.contentSize.width
        let centerOffset = (monthTitlesCollectionView.frame.width - monthTitleItemSize().width) / 2
        
        return CGPoint(x: monthTitlesCollectionView.contentSize.width * scrollPercentage - centerOffset,
                       y: contentOffset.y)
    }
    
    fileprivate func verticalHeaderBatchOffset(relatedTo contentOffset: CGPoint) -> CGPoint {
        
        let percentageOffset = contentOffset.y / calendarCollectionView.contentSize.height
        return CGPoint(x: contentOffset.x,
                       y: monthTitlesCollectionView.contentSize.height * percentageOffset)
    }
    
    fileprivate func monthTitleItemSize() -> CGSize {
        let width = isSurroundingMonthTitlesVisible
            ? monthTitlesCollectionView.frame.width / 2
            : monthTitlesCollectionView.frame.width
        
        return CGSize(width: width, height: monthTitlesCollectionView.frame.height)
    }
    
    
    // MARK: - Height constraint
    
    fileprivate func updateFloatingConstraint(newWeeksCount: Int, currentWeeksCount: Int, percentage: CGFloat) {
        
        let verticalInsetHeight = calendarSettings.contentInsets.top + calendarSettings.contentInsets.bottom
        let titleHeight = calendarSettings.monthTitleHeight
        let weekdaysHeight = calendarSettings.weekdaysTitleHeight
        
        
        let borderInset: CGFloat = calendarSettings.isDrawBorders ? calendarSettings.borderWidth : 0
        
        let yOffset = verticalInsetHeight + titleHeight + weekdaysHeight + borderInset
        
        
        let dayHeight = (self.frame.height - yOffset) / CGFloat(CalendarUtils.maxWeekInMonth)
        let delta = CGFloat(abs(newWeeksCount - currentWeeksCount))
        
        var currentOffSet: CGFloat = 0.0
        if currentWeeksCount != CalendarUtils.maxWeekInMonth {
            currentOffSet = -CGFloat((CalendarUtils.maxWeekInMonth - currentWeeksCount)) * dayHeight
        }
        
        if newWeeksCount > currentWeeksCount {
            currentOffSet += delta * dayHeight * percentage
        } else {
            currentOffSet -= delta * dayHeight * percentage
        }
        
        let changedBounds = CGRect(x: self.bounds.origin.x,
                                   y: self.bounds.origin.y,
                                   width: self.bounds.width,
                                   height: self.bounds.height + currentOffSet)
        
        self.calendarDelegate?.calendarView(self, boundingRectWillChange: changedBounds, changedHeight: currentOffSet)
    }
    
    fileprivate func isCalendarSizeValid() -> Bool {
        return calendarCollectionView.contentSize.width != 0.0 && calendarCollectionView.contentSize.height != 0.0
    }
    
}


// MARK: - MonthView

// MARK: MonthViewDelegate
extension CalendarView: MonthViewDelegate {
    
    func monthView(_ monthView: MonthView, didSelectDay day: Day) {
        
        guard day.type != .inout else {
            return
        }
        var isChanged = false
        
        if day.isSelected {
            
            if calendarDelegate?.calendarView(self, shouldDeselectDay: day) ?? true {
                
                calendarInfiniteDatasource?.deselect(day: day)
                calendarDelegate?.calendarView(self, didDeselectDay: day)
                isChanged = true
            }
            
        } else {
            var canSelectDay = true
            
            if !calendarSettings.allowsMultipleSelection {
                
                if let lastSelectedDay = calendarInfiniteDatasource?.lastSelectedDay {
                    
                    if calendarDelegate?.calendarView(self, shouldDeselectDay: lastSelectedDay) ?? true {
                        calendarInfiniteDatasource?.deselectLast()
                        isChanged = true
                    } else {
                        
                        // If user don't allow multiple selection and don't allow to deselect last selected day,
                        // we can't select current tapped day.
                        canSelectDay = false
                    }
                }
            }
            if canSelectDay && calendarDelegate?.calendarView(self, shouldSelectDay: day) ?? true {
                
                calendarInfiniteDatasource?.select(day: day)
                calendarDelegate?.calendarView(self, didSelectDay: day)
                isChanged = true
            }
        }
        if isChanged {
            reloadCollectionViews()
        }
    }
    
    func monthView(_ monthView: MonthView, dayAppearanceFor day: Day) -> DayAppearance? {
        return calendarDelegate?.calendarView(self, dayAppearanceFor: day)
    }
}

// MARK: MonthViewDataSource
extension CalendarView: MonthViewDataSource {
    func monthView(_ monthView: MonthView, countOfEventsForDay day: Day) -> Int {
        return self.calendarDelegate?.countOfEvents(for: day) ?? 0
    }
}

// MARK: - UICollectionView

// MARK: UICollectionViewDataSource
extension CalendarView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarInfiniteDatasource?.dateBatch.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = self.reuseIdentifier(for: collectionView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        return TypeDispatcher.value(cell)
            .dispatch { (cell: MonthCollectionViewCell) in
                
                if let month = self.calendarInfiniteDatasource?.month(at: indexPath) {
                    cell.setupWith(month: month, calendarSettings: calendarSettings, delegate: self, dataSource: self)
                }
            }
            .dispatch { (cell: MonthTitleCollectionViewCell) in
                
                if let month = self.calendarInfiniteDatasource?.month(at: indexPath) {
                    cell.setup(with: month, settings: calendarSettings)
                }
            }
            .dispatch { (cell: WeekdaysCollectionViewCell) in
                cell.setup(with: calendarSettings)
            }
            .extract()
    }
    
    private func reuseIdentifier(for collectionView: UICollectionView) -> String {
        switch collectionView {
        case calendarCollectionView:
            return MonthCollectionViewCell.reuseIdentifier
        case monthTitlesCollectionView:
            return MonthTitleCollectionViewCell.reuseIdentifier
        case weekdaysCollectionView:
            return WeekdaysCollectionViewCell.reuseIdentifier
        default:
            return ""
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case monthTitlesCollectionView where self.scrollDirection == .horizontal:
            return monthTitleItemSize()
        default:
            return CGSize(width: collectionView.frame.width / CGFloat(self.calendarSettings.visibleMonthCount),
                          height: collectionView.frame.height)
        }
    }
}

// MARK: UIScrollViewDelegate
extension CalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.calendarCollectionView else {
            return
        }
        self.scrollRelatedCollections(to: scrollView.contentOffset)
        
        guard calendarSettings.shouldAutoresizeHeight, let _ = self.calendarDelegate else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            do {
                var newCountOfWeeks: Int?
                var currentCountOfWeeks: Int?
                var percentage: CGFloat = 1.0
                
                let visibleItemsCount = self.calendarSettings.visibleMonthCount
                let pagingItemsCount = self.calendarSettings.pagingMonthCount
                
                let translationValue: CGFloat
                
                switch self.scrollDirection {
                case .horizontal:
                    translationValue = translation.x
                case .vertical:
                    translationValue = translation.y
                }
                
                let pageIndex = self.pageIndex(in: scrollView, translation: translationValue)
                percentage = self.swipePercentage(in: scrollView, pageIndex: pageIndex)
                
                // left or right swipe
                
                if translationValue > 0 {
                    guard pageIndex - 1 >= 0 else {
                        return
                    }
                    newCountOfWeeks = try self.calendarInfiniteDatasource?.countOfRows(for: visibleItemsCount, pagingItemsCount: pagingItemsCount, page: pageIndex - 1)
                    currentCountOfWeeks = try self.calendarInfiniteDatasource?.countOfRows(for: visibleItemsCount, pagingItemsCount: pagingItemsCount, page: pageIndex)
                    
                } else if translationValue < 0 {
                    guard pageIndex + 1 < (self.calendarSettings.pagingMonthCount * 2 + visibleItemsCount) / visibleItemsCount else {
                        return
                    }
                    newCountOfWeeks = try self.calendarInfiniteDatasource?.countOfRows(for: visibleItemsCount, pagingItemsCount: pagingItemsCount, page: pageIndex + 1)
                    currentCountOfWeeks = try self.calendarInfiniteDatasource?.countOfRows(for: visibleItemsCount, pagingItemsCount: pagingItemsCount, page: pageIndex)
                } else {
                    return
                }
                
                if newCountOfWeeks != currentCountOfWeeks {
                    DispatchQueue.main.async {
                        self.updateFloatingConstraint(newWeeksCount: newCountOfWeeks!, currentWeeksCount: currentCountOfWeeks!, percentage: percentage)
                    }
                }
            } catch {
                debugPrint(error)
            }
            
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.calendarCollectionView else { return }
        
        let visibleMonthCount = calendarSettings.visibleMonthCount
        let pagingCount = calendarSettings.pagingMonthCount
        
        let pageIndex: Int
        switch self.scrollDirection {
        case .horizontal:
            pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        case .vertical:
            pageIndex = Int(scrollView.contentOffset.y / scrollView.frame.height)
        }
        
        if pageIndex == 0 {
            
            scrollView.isUserInteractionEnabled = false
            self.calendarInfiniteDatasource?.loadPrevious(count: pagingCount) {
                scrollView.isUserInteractionEnabled = true
                self.reloadCalendar()
            }
        } else if pageIndex == (visibleMonthCount + 2 * pagingCount) / visibleMonthCount - 1 {
            
            scrollView.isUserInteractionEnabled = false
            self.calendarInfiniteDatasource?.loadNext(count: pagingCount) {
                self.reloadCalendar()
                scrollView.isUserInteractionEnabled = true
            }
        }
    }
    
    private func pageIndex(in scrollView: UIScrollView, translation: CGFloat) -> Int {
        
        let index: CGFloat
        switch self.scrollDirection {
        case .horizontal:
            index = scrollView.contentOffset.x / scrollView.frame.width
        case .vertical:
            index = scrollView.contentOffset.y / scrollView.frame.height
        }
        
        if translation > 0 {
            return Int(ceil(index))
        } else {
            return Int(floor(index))
        }
    }
    
    private func swipePercentage(in scrollView: UIScrollView, pageIndex: Int) -> CGFloat {
        switch self.scrollDirection {
        case .horizontal:
            return abs(scrollView.contentOffset.x / scrollView.frame.width - CGFloat(pageIndex))
        case .vertical:
            return abs(scrollView.contentOffset.y / scrollView.frame.height - CGFloat(pageIndex))
        }
    }
    
    private func scrollRelatedCollections(to contentOffset: CGPoint) {
        switch self.scrollDirection {
        case .horizontal:
            
            if isCalendarSizeValid() {
                let offset = horizontalHeaderBatchOffset(relatedTo: contentOffset)
                monthTitlesCollectionView.setContentOffset(offset, animated: false)
            }
            
            if calendarSettings.shouldScrollWeekdays {
                weekdaysCollectionView.setContentOffset(contentOffset, animated: false)
            }
        case .vertical:
            let offset = verticalHeaderBatchOffset(relatedTo: contentOffset)
            monthTitlesCollectionView.setContentOffset(offset, animated: false)
        }
    }
}
