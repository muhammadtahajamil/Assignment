//import AppKit
import SwiftUI

@main
struct PureLogicsMacApp: App {
    
    @State private var isOffline = false
//    @State private var testString = "Taha"
    @State private var sessionstore = UserSessionStore()
    
    private var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                 if sessionstore.isAuthenticated {
                    AuthenticatedSessionView()
                } else {
                    SignInView()
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

