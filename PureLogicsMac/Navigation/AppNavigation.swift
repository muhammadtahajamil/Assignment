import Foundation
import SwiftUI

enum SidebarSection: String, CaseIterable, Identifiable {
    
    case dashboard
    case users
    case fileProcessing
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        
        case .dashboard: "Dashboard"
        case .users: "Users"
        case .fileProcessing: "File Processing"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "chart.bar.xaxis"
        case .users: "person.2"
        case .fileProcessing: "doc.badge.gearshape"
        case .settings: "gearshape.2"
        }
    }
}

enum DashboardDestination: Hashable {
//    case overview
    case statistics
    case activity
}

enum UsersDestination: Hashable {
//    case list
    case detail(UserRecord.ID)
    case activity(UserRecord.ID)
}

enum FileDestination: Hashable {
//    case browser
    case details
    case hashResults
}

enum settingsDestination: Hashable {
    case general
    case devices
}

@MainActor
final class AppNavigation: ObservableObject {
    @Published var selectedSection: SidebarSection? = .dashboard
    @Published var dashboardPath = NavigationPath()
    @Published var usersPath = NavigationPath()
    @Published var filePath = NavigationPath()
    @Published var settingsPath = NavigationPath()
}
