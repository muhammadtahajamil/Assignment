
import SwiftUI
import SwiftData

@main
struct PureLogicsMacApp: App {
    
    private var container = AppDependencyConatainer()
    @State var sessionStore: UserSessionStore
    
    init() {
        let container = AppDependencyConatainer()
        self.container = container
        self._sessionStore = State(wrappedValue: container.sessionStore)
    }
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                 if sessionStore.isAuthenticated {
                    AuthenticatedSessionView()
//                     AuthNavigationViewTest()
                } else {
                    AuthNavigationView()
                        .edgesIgnoringSafeArea(.top)
                        .frame(width: 840, height: 626)
                }
            }
            .environment(sessionStore)
        }
        .modelContainer(for : [UserSessionModel.self, SubscriptionDetailsModel.self ,UserDevicesModel.self, DevicesInfo.self])
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
        }
    }
}
