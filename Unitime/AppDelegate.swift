//
//  AppDelegate.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import Cocoa
import SwiftUI
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBar: StatusBarController!
    var menu: Menu!

    var showSecondsSetting = Setting<Bool>(named: "showSeconds", defaultingTo: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menu = Menu()
        menu.delegate = self

        statusBar = StatusBarController(withMenu: menu.mainMenu)
        statusBar.showSeconds = showSecondsSetting.value
        statusBar.start()

        menu.setShowSeconds(statusBar.showSeconds)
        menu.setLaunchAtLogin(LaunchAtLogin.isEnabled)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

extension AppDelegate: MenuDelegate {

    func menuDidToggleShowSeconds() -> Bool {
        let newValue = showSecondsSetting.toggle()
        statusBar.showSeconds = newValue
        return newValue
    }

    func menuDidToggleLaunchAtLogin() -> Bool {
        let newValue = !LaunchAtLogin.isEnabled
        LaunchAtLogin.isEnabled = newValue
        return newValue
    }

    func menuDidChooseQuit() {
        NSApp.terminate(nil)
    }

}
