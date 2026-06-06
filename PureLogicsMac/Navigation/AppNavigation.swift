import Foundation
import SwiftUI

enum SidebarSection: String, CaseIterable, Identifiable {
    case dashboard
    case users
    case fileProcessing

    var id: Self { self }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .users: "Users"
        case .fileProcessing: "File Processing"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "chart.bar.xaxis"
        case .users: "person.3"
        case .fileProcessing: "doc.badge.gearshape"
        }
    }
}

enum DashboardDestination: Hashable {
    case overview
    case statistics
    case activity
}

enum UsersDestination: Hashable {
    case list
    case detail(UserRecord.ID)
    case activity(UserRecord.ID)
}

enum FileDestination: Hashable {
    case browser
    case details
    case hashResults
}

@MainActor
final class AppNavigation: ObservableObject {
    @Published var selectedSection: SidebarSection? = .dashboard
    @Published var dashboardPath = NavigationPath()
    @Published var usersPath = NavigationPath()
    @Published var filePath = NavigationPath()
}
