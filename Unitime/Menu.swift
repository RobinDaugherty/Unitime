//
//  Menu.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import AppKit

protocol MenuDelegate: AnyObject {
    func menuDidToggleShowSeconds() -> Bool
    func menuDidChooseQuit()
}

class Menu {

    public var mainMenu: NSMenu

    private var showSecondsItem: NSMenuItem

    private var quitItem: NSMenuItem

    public weak var delegate: MenuDelegate?

    init() {
        mainMenu = NSMenu()

        showSecondsItem = mainMenu.addItem(withTitle: "Show seconds", action: #selector(didChooseShowSeconds(_:)), keyEquivalent: "")

        mainMenu.addItem(NSMenuItem.separator())

        quitItem = mainMenu.addItem(withTitle: "Quit", action: #selector(didChooseQuit(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]

        showSecondsItem.target = self
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

    @objc
    func didChooseQuit(_ sender: NSMenuItem) {
        delegate?.menuDidChooseQuit()
    }

}
