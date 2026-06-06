import AppKit
import SwiftUI

@main
struct PureLogicsMacApp: App {
    @StateObject private var navigation = AppNavigation()
    @StateObject private var userStore: UserStore
    @StateObject private var fileStore = FileProcessingStore()

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false

        let database = AppDatabase.makeDefault()
        let repository = UserRepository(
            apiClient: DummyJSONUserAPIClient(),
            database: database
        )
        _userStore = StateObject(wrappedValue: UserStore(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navigation)
                .environmentObject(userStore)
                .environmentObject(fileStore)
                .frame(minWidth: 980, minHeight: 640)
                .task {
                    await userStore.load()
                }
        }
        .windowResizability(.contentMinSize)
        .commands {
            SidebarCommands()
        }
    }
}
