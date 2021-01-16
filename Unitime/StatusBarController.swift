//
//  StatusBarController.swift
//  Timebar
//
//  Created by Robin Daugherty on 2021-01-16.
//

import AppKit

class StatusBarController {

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

        let now = Date()
        let intervalUntilFirstTimer = timerPeriod - now.timeIntervalSince1970.remainder(dividingBy: timerPeriod)
        debugPrint("intervalUntilFirstTimer expired")
        Timer.scheduledTimer(withTimeInterval: intervalUntilFirstTimer, repeats: false) { timer in
            debugPrint("intervalUntilFirstTimer fired")
            self.updateDisplayedTime()
            self.scheduleTimer()
        }
    }

    private func scheduleTimer() {
        if let existingTimer = runningTimer {
            existingTimer.invalidate()
        }

        runningTimer = Timer.scheduledTimer(timeInterval: timerPeriod, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
    }

    @objc
    func timerFired(_ sender: Timer) {
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
