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
            }
            label: {
                Label("Open Devices", systemImage: "chart.xyaxis.line")
            }
            .buttonStyle(.borderedProminent)
            
            Button(role: .destructive){
//                navigation.dashboardPath = NavigationPath()
//                navigation.settingsPath = NavigationPath()
                navigation.reset()
                session.logout()
                
            }label: {
                Label("Sign Out", image: "rectangle.portrait.and.arrow.right")
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
