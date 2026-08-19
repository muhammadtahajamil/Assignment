
import SwiftUI
import SwiftData

@main
struct PureLogicsMacApp: App {
    
    private var container = AppDependencyConatainer()
    @State var sessionStore: UserSessionStore
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let container = AppDependencyConatainer()
        self.container = container
        _sessionStore = State(wrappedValue: container.sessionStore)
    }
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                 if sessionStore.isAuthenticated {
//                    AuthenticatedSessionView()
                     HomeView()
                } else {
                    AuthNavigationView()
                }
            }
            .environment(sessionStore)
            .edgesIgnoringSafeArea(.top)
            .frame(width: 840, height: 626)
        }
        .modelContainer(for : [UserSessionModel.self, SubscriptionDetailsModel.self ,UserDevicesModel.self, DevicesInfo.self])
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .active:
                print("print active")
            case .inactive:
                print("print In active")
            case .background:
                print("print background")
            @unknown default:
                break
            }
        }
    }
}
