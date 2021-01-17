//
//  StatusBarController.swift
//  Timebar
//
//  Created by Robin Daugherty on 2021-01-16.
//

import AppKit

class StatusBarController {

    private lazy var debugLogDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSSSS"
        return formatter
    }()

    private var statusBar: NSStatusBar

    private var statusItem: NSStatusItem

    public var showSeconds: Bool = false {
        didSet {
            updateDisplayedTime(beforeFirstFullPeriod: true)

            if runningTimer != nil {
                self.scheduleTimer()
            }
        }
    }

    private var runningTimer: Timer?

    private var timerPeriod: TimeInterval {
        showSeconds ? 1 : 60
    }

    init(withMenu menu: NSMenu) {
        statusBar = NSStatusBar()

        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = menu
    }

    public func start() {
        updateDisplayedTime(beforeFirstFullPeriod: true)
        scheduleTimer()
    }

    private func scheduleTimer() {
        if let existingTimer = runningTimer {
            existingTimer.invalidate()
        }

        let now = Date()
        let nowInterval = now.timeIntervalSince1970
        debugPrint("scheduleTimer() called at \(debugLogDateFormatter.string(from: now)): \(nowInterval)")

        let remainder = nowInterval.truncatingRemainder(dividingBy: timerPeriod)
        debugPrint("remainder until next timer period (\(timerPeriod)) is \(remainder)")

        let intervalUntilFirstTimer = timerPeriod - remainder
        debugPrint("the first interval expires in \(intervalUntilFirstTimer) seconds")

        runningTimer = Timer.scheduledTimer(withTimeInterval: intervalUntilFirstTimer, repeats: false) { [self] timer in
            debugPrint("first interval timer fired at \(debugLogDateFormatter.string(from: Date()))")
            updateDisplayedTime()
            runningTimer = Timer.scheduledTimer(timeInterval: timerPeriod, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
        }
    }

    @objc
    func timerFired(_ sender: Timer) {
        debugPrint("interval timer fired at \(debugLogDateFormatter.string(from: Date()))")
        updateDisplayedTime()
    }

    /// Use an ISO8601 formatter to ensure that no user preferences affect the way it formats the date/time.
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.formatOptions = [
            .withFullDate,
            .withDashSeparatorInDate,
            .withSpaceBetweenDateAndTime,
            .withTime,
            .withColonSeparatorInTime,
        ]

        return formatter
    }()

    private lazy var titleFont: NSFont = {
        let smallSize = NSFont.systemFontSize(for: .small)
        let regularSize = NSFont.systemFontSize(for: .regular)
        let mediumSize = (smallSize + regularSize) / 2
        return NSFont.monospacedDigitSystemFont(ofSize: mediumSize, weight: .light)
    }()

    private lazy var titleDeltaFont: NSFont = {
        let smallSize = NSFont.systemFontSize(for: .small)
        let regularSize = NSFont.systemFontSize(for: .regular)
        let mediumSize = (smallSize + regularSize) / 2
        return NSFont.monospacedDigitSystemFont(ofSize: mediumSize, weight: .bold)
    }()

    private lazy var titleAttributes: [NSAttributedString.Key: Any] = {

        return [
            .font: titleFont,
        ]
    }()

    /// If beforeFirstFullPeriod is true, the current time is shown rounded to the nearest second. When false, the time is rounded to nearest minute if showSeconds is disabled.
    private func updateDisplayedTime(beforeFirstFullPeriod: Bool = false) {
        guard let button = statusItem.button else { return }

        let now: Date
        if showSeconds || beforeFirstFullPeriod {
            // Rounded to the nearest minute/second so that the correct time is shown even if timer fires slightly before the second.
            now = Date().roundedToNearestSecond
        } else {
            // But if we round to the nearest minute when the app first launches, it might round up and show the "wrong" time until the timer ticks.
            // So round to the nearest minute only when handling a timer tick.
            // Why round to the minute? Recurring timers seem to fire ahead and behind the exact time you'd expect.
            // On longer timers, like 60 seconds, I have little confidence that they will fire on the right second, so second-rounding wouldn't be enough.
            now = Date().roundedToNearestMinute
        }

        button.attributedTitle = attributedTextForDate(now)
    }

    func attributedTextForDate(_ date: Date) -> NSAttributedString {
        let dateString = dateFormatter.string(from: date, showingSeconds: showSeconds)

        let text = NSMutableAttributedString(string: dateString, attributes: titleAttributes)
        let componentsThatDifferInUTC = date.componentsThatDifferInUTC

        if componentsThatDifferInUTC.contains(.year) {
            text.setAttributes([NSAttributedString.Key.font: titleDeltaFont], range: NSMakeRange(0, 4))
        }
        if componentsThatDifferInUTC.contains(.month) {
            text.setAttributes([NSAttributedString.Key.font: titleDeltaFont], range: NSMakeRange(5, 2))
        }
        if componentsThatDifferInUTC.contains(.day) {
            text.setAttributes([NSAttributedString.Key.font: titleDeltaFont], range: NSMakeRange(8, 2))
        }

        return text
    }

}

extension Date {

    var roundedToNearestMinute: Date {
        let nearestIntervalMinutes = (timeIntervalSince1970 / 60).rounded()
        return Date(timeIntervalSince1970: (nearestIntervalMinutes * 60))
    }

    var roundedToNearestSecond: Date {
        return Date(timeIntervalSince1970: timeIntervalSince1970.rounded())
    }

    var componentsThatDifferInUTC: Set<Calendar.Component> {
        let calendar = Calendar(identifier: .gregorian)
        let utcZone = TimeZone(identifier: "UTC")!
        let utcComponents = calendar.dateComponents(in: utcZone, from: self)
        let localComponents = calendar.dateComponents([.year, .month, .day], from: self)

        if utcComponents.year != localComponents.year {
            return [.day, .month, .year]
        } else if utcComponents.month != localComponents.month {
            return [.day, .month]
        } else if utcComponents.day != localComponents.day {
            return [.day]
        }
        return []
    }

}

extension ISO8601DateFormatter {

    func string(from date: Date, showingSeconds: Bool) -> String {
        let dateString: String = string(from: date)
        if showingSeconds {
            return dateString
        } else {
            return String(dateString[dateString.startIndex ..< dateString.index(dateString.endIndex, offsetBy: -3) ])
        }
    }

}
