//import AppKit
import SwiftUI

@main
struct PureLogicsMacApp: App {
    
    @State private var isLoggedIn = false
    @State private var isOffline = false
//    @State private var testString = "Taha"
    @State private var sessionstore = UserSessionStore()

    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                if isLoggedIn {
                    AuthenticatedSessionView()
                        
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, isOffline: $isOffline, sessionStore: sessionstore)
                }
            }
            .frame(minWidth: 800, minHeight: 600)
            .environment(sessionstore)
        }
        .windowResizability(.contentMinSize)
        .commands {
            SidebarCommands()
        }
    }
}


