//
//  AuthenticatedSessionView.swift
//  PureLogicsMac
//
//  Created by Apple on 16/07/2026.
//
import SwiftUI

struct AuthenticatedSessionView: View {
    @StateObject private var navigation = AppNavigation()
    @StateObject private var userStore: UserStore
    @StateObject private var fileStore = FileProcessingStore()

    init() {
        // This database connection is ONLY created after a successful login!
        let database = AppDatabase.makeDefault()
        let repository = UserRepository(
            apiClient: DummyJSONUserAPIClient(),
            database: database
        )
        _userStore = StateObject(wrappedValue: UserStore(repository: repository))
    }

    var body: some View {
        AppMainNavigationView()
            .environmentObject(navigation)
            .environmentObject(userStore)
            .environmentObject(fileStore)
            .task {
                await userStore.load()
            }
    }
}
