//
//  AppDelegate.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBar: StatusBarController!
    var menu: Menu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menu = Menu()
        menu.delegate = self

        statusBar = StatusBarController(withMenu: menu.mainMenu)
        statusBar.start()

        menu.setShowSeconds(statusBar.showSeconds)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

extension AppDelegate: MenuDelegate {

    func menuDidToggleShowSeconds() -> Bool {
        let newValue = !statusBar.showSeconds
        statusBar.showSeconds = newValue
        return newValue
    }

    func menuDidChooseQuit() {
        NSApp.terminate(nil)
    }

}
