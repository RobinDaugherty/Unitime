//
//  AppDelegate.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBar: StatusBarController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBar = StatusBarController()
        statusBar.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
