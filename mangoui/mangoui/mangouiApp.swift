//
//  mangouiApp.swift
//  mangoui
//
//  Created by 小沫 on 2023/5/30.
//

import SwiftUI

@main
struct mangouiApp: App {
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
    var body: some Scene {
        WindowGroup {
            MGContentView()
        }
    }
}
