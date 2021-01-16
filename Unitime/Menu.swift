//
//  Menu.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import AppKit

protocol MenuDelegate: AnyObject {
    func menuDidToggleShowSeconds() -> Bool
    func menuDidToggleLaunchAtLogin() -> Bool
    func menuDidChooseQuit()
}

class Menu {

    public var mainMenu: NSMenu

    private var showSecondsItem: NSMenuItem

    private var launchAtLoginItem: NSMenuItem

    private var quitItem: NSMenuItem

    public weak var delegate: MenuDelegate?

    init() {
        mainMenu = NSMenu()

        showSecondsItem = mainMenu.addItem(withTitle: NSLocalizedString("Show seconds", comment: "Menu item that can be toggled which indicates whether seconds are shown"), action: #selector(didChooseShowSeconds(_:)), keyEquivalent: "")

        launchAtLoginItem = mainMenu.addItem(withTitle: NSLocalizedString("Launch at login", comment: "Menu item that can be toggled which indicates whether the app will be launches at startup"), action: #selector(didChooseLaunchAtLogin(_:)), keyEquivalent: "")

        mainMenu.addItem(NSMenuItem.separator())

        quitItem = mainMenu.addItem(withTitle: NSLocalizedString("Quit", comment: "Menu item that causes the app to quit"), action: #selector(didChooseQuit(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]

        showSecondsItem.target = self
        launchAtLoginItem.target = self
        quitItem.target = self
    }

    public func setShowSeconds(_ value: Bool) {
        showSecondsItem.state = value ? .on : .off
    }

    @objc
    func didChooseShowSeconds(_ sender: NSMenuItem) {
        if let nowEnabled = delegate?.menuDidToggleShowSeconds() {
            sender.state = nowEnabled ? .on : .off
        }
    }

    public func setLaunchAtLogin(_ value: Bool) {
        launchAtLoginItem.state = value ? .on : .off
    }

    @objc
    func didChooseLaunchAtLogin(_ sender: NSMenuItem) {
        if let nowEnabled = delegate?.menuDidToggleLaunchAtLogin() {
            sender.state = nowEnabled ? .on : .off
        }
    }

    @objc
    func didChooseQuit(_ sender: NSMenuItem) {
        delegate?.menuDidChooseQuit()
    }

}
