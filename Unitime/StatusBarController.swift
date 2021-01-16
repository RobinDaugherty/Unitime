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

    private lazy var noSecondsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-DD HH:mm"
        return formatter
    }()

    private lazy var withSecondsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-DD HH:mm:ss"
        return formatter
    }()

    private var dateFormatter: DateFormatter {
        showSeconds ? withSecondsDateFormatter : noSecondsDateFormatter
    }

    /// If beforeFirstFullPeriod is true, the current time is shown rounded to the nearest second. When false, the time is rounded to nearest minute if showSeconds is disabled.
    private func updateDisplayedTime(beforeFirstFullPeriod: Bool = false) {
        guard let button = statusItem.button else { return }

        let nowSeconds = Date().timeIntervalSince1970
        let roundedNow: Date
        // Rounded to the nearest minute/second so that the correct time is shown even if timer fires slightly before the second.
        if showSeconds || beforeFirstFullPeriod {
            roundedNow = Date(timeIntervalSince1970: nowSeconds.rounded())
        } else {
            let nearestIntervalMinutes = (nowSeconds / 60).rounded()
            roundedNow = Date(timeIntervalSince1970: (nearestIntervalMinutes * 60))
        }

        button.title = dateFormatter.string(from: roundedNow)
    }

}
