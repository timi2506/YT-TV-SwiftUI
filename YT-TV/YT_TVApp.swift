//
//  YT_TVApp.swift
//  YT-TV
//
//  Created by @timi2506 on 09.12.2024.
//

import SwiftUI

@main
struct YT_TVApp: App {
    @AppStorage("ResetOnLaunch") var relaunch = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Menu("Advanced") {
                    Button("Empty Cache") {
                        relaunch = true
                        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
                        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
                        let task = Process()
                        task.launchPath = "/usr/bin/open"
                        task.arguments = [path]
                        task.launch()
                        exit(0)
                    }
                }
                
            }
        }
        #endif
    }
}
