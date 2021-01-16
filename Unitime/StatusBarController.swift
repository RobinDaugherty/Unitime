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

    private lazy var titleAttributes: [NSAttributedString.Key: Any] = {
        let smallSize = NSFont.systemFontSize(for: .small)
        let regularSize = NSFont.systemFontSize(for: .regular)
        let mediumSize = (smallSize + regularSize) / 2
        let font = NSFont.monospacedDigitSystemFont(ofSize: mediumSize, weight: .light)

        return [
            .font: font,
        ]
    }()

    /// If beforeFirstFullPeriod is true, the current time is shown rounded to the nearest second. When false, the time is rounded to nearest minute if showSeconds is disabled.
    private func updateDisplayedTime(beforeFirstFullPeriod: Bool = false) {
        guard let button = statusItem.button else { return }

        let nowSeconds = Date().timeIntervalSince1970
        let roundedNow: Date
        if showSeconds || beforeFirstFullPeriod {
            // Rounded to the nearest minute/second so that the correct time is shown even if timer fires slightly before the second.
            roundedNow = Date(timeIntervalSince1970: nowSeconds.rounded())
        } else {
            // But if we round to the nearest minute when the app first launches, it might round up and show the "wrong" time until the timer ticks.
            // So round to the nearest minute only when handling a timer tick.
            let nearestIntervalMinutes = (nowSeconds / 60).rounded()
            roundedNow = Date(timeIntervalSince1970: (nearestIntervalMinutes * 60))
        }

        var dateString = dateFormatter.string(from: roundedNow)
        if !showSeconds {
            dateString.removeLast(3)
        }

        let text = NSAttributedString(string: dateString, attributes: titleAttributes)
        button.attributedTitle = text
    }

}
