//import AppKit
import SwiftUI

@main
struct PureLogicsMacApp: App {
    
    @State private var isOffline = false
    @State private var sessionstore = UserSessionStore()
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                 if sessionstore.isAuthenticated {
                    AuthenticatedSessionView()
//                     AuthNavigationViewTest()
                } else {
                    AuthNavigationView()
                        .edgesIgnoringSafeArea(.top)
                        .frame(width: 840, height: 626)
                }
            }
            .environment(sessionstore)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
        }
    }
}

