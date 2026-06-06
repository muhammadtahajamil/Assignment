import SwiftUI

struct RootView: View {
    @EnvironmentObject private var navigation: AppNavigation

    var body: some View {
        NavigationSplitView {
            List(selection: $navigation.selectedSection) {
                ForEach(SidebarSection.allCases) { section in
                    Label(section.title, systemImage: section.systemImage)
                        .tag(section)
                }
            }
            .navigationTitle("PureLogics")
        } detail: {
            switch navigation.selectedSection ?? .dashboard {
            case .dashboard:
                NavigationStack(path: $navigation.dashboardPath) {
                    DashboardOverviewView()
                        .navigationDestination(for: DashboardDestination.self) { destination in
                            switch destination {
                            case .overview: DashboardOverviewView()
                            case .statistics: DashboardStatisticsView()
                            case .activity: DashboardActivityView()
                            }
                        }
                }
            case .users:
                NavigationStack(path: $navigation.usersPath) {
                    UserListView()
                        .navigationDestination(for: UsersDestination.self) { destination in
                            switch destination {
                            case .list:
                                UserListView()
                            case .detail(let id):
                                UserDetailView(userID: id)
                            case .activity(let id):
                                UserActivityView(userID: id)
                            }
                        }
                }
            case .fileProcessing:
                NavigationStack(path: $navigation.filePath) {
                    FileBrowserView()
                        .navigationDestination(for: FileDestination.self) { destination in
                            switch destination {
                            case .browser: FileBrowserView()
                            case .details: FileDetailsView()
                            case .hashResults: HashResultsView()
                            }
                        }
                }
            }
        }
    }
}
