//
//  AuthNavigationView.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import SwiftUI
import Observation

enum AuthRoute {
    case signIn
    case signUp
    case verifyAccount
}

@MainActor
@Observable final class AuthNavigationStore {
    var currentRoute: AuthRoute = .signIn
    
    func showSignIn() {
        currentRoute = .signIn
    }
    
    func showSignUp() {
        currentRoute = .signUp
    }
    
    func showVerifyAccount() {
        currentRoute = .verifyAccount
    }
}

struct AuthNavigationView: View {
    @State private var navigationStore = AuthNavigationStore()
    private let loginUseCase: LoginUseCase
    
    init() {
        let apiClient = DefaultAPIClient(environment: .development)
        let remoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
        let repository = DefaultAuthRepository(remoteDataSource: remoteDataSource)
        self.loginUseCase = LoginUseCase(repository: repository)
    }
    
    var body: some View {
        ZStack {
            switch navigationStore.currentRoute {
            case .signIn:
                SignInView()
            case .signUp:
                SignUpView()
            case .verifyAccount:
                VerifyAccountView()
            }
        }
        .environment(navigationStore)
    }
}
