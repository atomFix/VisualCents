//
//  SideMenuAction.swift
//  VisualCents
//
//  Environment key for controlling the side menu
//

import SwiftUI

/// Action to toggle the side menu
struct SideMenuOpenAction {
    let action: () -> Void
    
    func callAsFunction() {
        action()
    }
}

struct SideMenuOpenActionKey: EnvironmentKey {
    static let defaultValue: SideMenuOpenAction = SideMenuOpenAction(action: {})
}

extension EnvironmentValues {
    var openSideMenu: SideMenuOpenAction {
        get { self[SideMenuOpenActionKey.self] }
        set { self[SideMenuOpenActionKey.self] = newValue }
    }
}
