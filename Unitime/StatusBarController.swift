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
            // Just in case this value changes before 
            if runningTimer != nil {
                self.scheduleTimer()
            }
        }
    }

    private var runningTimer: Timer?

    private var timerPeriod: TimeInterval {
        showSeconds ? 1 : 60
    }

    init() {
        statusBar = NSStatusBar()

        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "Unitime"
        }

    }

    public func start() {
        updateDisplayedTime()
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

        let intervalUntilFirstTimer = (timerPeriod - remainder)
        debugPrint("the first interval expires in \(intervalUntilFirstTimer) seconds")

        Timer.scheduledTimer(withTimeInterval: intervalUntilFirstTimer, repeats: false) { [self] timer in
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

    private func updateDisplayedTime() {
        if let button = statusItem.button {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.init(identifier: "UTC")
            var format = "yyyy-MM-DD HH:mm"
            if showSeconds {
                format.append(":ss")
            }
            formatter.dateFormat = format
            button.title = formatter.string(from: Date())
        }
    }

}
