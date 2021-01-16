//
//  Setting.swift
//  Unitime
//
//  Created by Robin Daugherty on 2021-01-16.
//

import Foundation

class Setting<T> {

    private let name: String

    private let defaultValue: T

    init(named name: String, defaultingTo defaultValue: T) {
        self.name = name
        self.defaultValue = defaultValue
    }

    public var value: T {
        get {
            (UserDefaults.standard.object(forKey: name) as? T) ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: name)
        }
    }

}

extension Setting where T == Bool {

    func toggle() -> Bool {
        let newValue = !value
        value = newValue
        return newValue
    }

}
