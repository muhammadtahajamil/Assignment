//
//  LoginViewModel.swift
//  PureLogicsMac
//
//  Created by Apple on 14/07/2026.
//

import Foundation


@MainActor
@Observable final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var errorMessage: String?
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    var isOffline : Bool = false
    
    var userAuthInfo: AuthResponseDTO?
    
    private let useCase: LoginUseCase
    private let sessionStore: UserSessionStore
    
    init(useCase: LoginUseCase, sessionStore: UserSessionStore) {
        self.useCase = useCase
        self.sessionStore = sessionStore
    }
    
    func loginButtonTapped() async {
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        isLoading = true
        do {
            let authInfo = try await useCase.readAuth(param: trimmedEmail)
            self.userAuthInfo = authInfo
            self.sessionStore.authData = authInfo
            print("Successfully loaded AuthInfo for: \(authInfo.email) (ID: \(authInfo.id))")
            self.isLoggedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    func checkInternet(){
        guard Connectivity.shared.isConnectedToWiFi else {
            return
        }
        isOffline = true
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
//    func SignInResponse(parameter:String) async ->(Bool, String) {
//        
//    }
}
