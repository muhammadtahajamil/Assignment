//
//  SettingViews.swift
//  PureLogicsMac
//
//  Created by Apple on 09/07/2026.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @Environment(UserSessionStore.self) private var session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Text("This is setting view \(session.currentUser?.email ?? "None")")
                .font(.headline)
            Button {
                navigation.settingsPath.append(settingsDestination.devices)
            } label: {
                Label("Open Devices", systemImage: "chart.xyaxis.line")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            ContentUnavailableView("No Device Found", systemImage: "doc.badge.plus")
                .frame(maxWidth: .infinity, minHeight: 260)
           
        }
        .padding(20)
        .navigationTitle("Settings")
    }
}
