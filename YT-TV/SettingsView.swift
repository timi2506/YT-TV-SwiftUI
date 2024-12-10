//
//  SettingsView.swift
//  YT-TV
//
//  Created by @timi2506 on 09.12.2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            UserAgentsView()
                .tabItem {
                    Image(systemName: "tv.badge.wifi")
                    Text("User Agents")
                }
            
            EmptyView()
                .tabItem {
                    Image(systemName: "apple.logo")
                    Text("Placeholder")
                }
        }
    }
}

struct UserAgentsView: View {
    @State private var custom = false
    @State private var customUserAgent = ""
    @AppStorage("ResetOnLaunch") var relaunch = false
    @AppStorage("Selected User Agent ID") private var selectedUserAgent = 0
    @AppStorage("User Agent") var userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edge/44.19041.4788"
    var body: some View {
        List {
            Text("Note: Shake your iPhone to quickly Reset Cache or Press Reset Cache in the Menu Bar Group ")
            Picker("User Agent", selection: $selectedUserAgent) {
                Section("Default") {
                    Text("Xbox - Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edge/44.19041.4788")
                        .tag(0)
                }
                Section("Apple TV") {
                    Text("AppleTV - AppleCoreMedia/1.0.0.21K69 (Apple TV; U; CPU OS 17_1 like Mac OS X; zh_tw)")
                        .tag(1)
                }
                Section("Custom") {
                    Text("Custom: " + customUserAgent)
                        .tag(-1)
                }
            }
            .onChange(of: selectedUserAgent) { newValue in
                if selectedUserAgent == 0 {
                    userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edge/44.19041.4788"
                }
                if selectedUserAgent == 1 {
                    userAgent = "AppleCoreMedia/1.0.0.21K69 (Apple TV; U; CPU OS 17_1 like Mac OS X; zh_tw)"
                }
                relaunch = true
            }
            if selectedUserAgent == -1 {
                TextField("Custom User Agent", text: $customUserAgent, onCommit: {userAgent = customUserAgent})
            }
        }
    }
}
