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
    var isPasswordVisible: Bool = true
    var errorMessage: String?
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    var isOffline : Bool = false
    
    private let useCase: LoginUseCase
    private let sessionStore: UserSessionStore
    private let deviceRepository: DeviceRepository
    
    init(useCase: LoginUseCase, sessionStore: UserSessionStore, deviceAuthRepository: DeviceRepository) {
        self.useCase = useCase
        self.sessionStore = sessionStore
        self.deviceRepository = deviceAuthRepository
    }
    
     func loginButtonTapped() async {
         isLoading = true
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        //Validate form
        if let validateError = validateForm(email: trimmedEmail, password: password){
            self.errorMessage = validateError
            return
        }
        errorMessage = nil
        //
         defer {
             isLoading = false
         }
         do {
             async let login = try await useCase.authenticateUser(
                email: trimmedEmail, password: password)
             async let devices = try await deviceRepository.fetchDevices(parameter: "123456789")
             
             print("Successfully fetched \( try await devices.count) devices for user.")
//             self.sessionStore.authData = login
//             self.sessionStore.deviceList = devices
         }catch{
             self.errorMessage = error.localizedDescription
         }
        //Auth Request
        do {
            let loginResponse = try await useCase.authenticateUser(
                email: trimmedEmail,
                password: password
            )
           //get devices List
            let devices = try await deviceRepository.fetchDevices(parameter: loginResponse.id!)
                    print("Successfully fetched \(devices.count) devices for user.")
            self.sessionStore.authData = loginResponse
            self.sessionStore.deviceList = devices
            self.isLoggedIn = true
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func checkInternet()->Bool{
        guard Connectivity.shared.isConnectedToWiFi else {
            return false
        }
        isOffline = false
        return true
    }
    private func validateForm(email: String, password: String) -> String? {
//        if checkInternet() { return "No internet connection."}
        if email.isEmpty { return "Please enter your email." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        if password.isEmpty { return "Please enter your password." }
        if password.count < 6 {
            return "Password must be at least 6 characters."
        }
        return nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
