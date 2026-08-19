//
//  LoginViewModel.swift
//  PureLogicsMac
//
//  Created by Apple on 14/07/2026.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var errorMessage: String?
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    var isOffline : Bool = false
    var isLinkedDevices : Bool = false
    
    
    private let useCase: LoginUseCase
    private let sessionStore: UserSessionStore
    private let deviceRepository: DeviceRepository
    private let modelContext : ModelContext

    
    init(useCase: LoginUseCase, sessionStore: UserSessionStore, deviceAuthRepository: DeviceRepository, modelContext: ModelContext) {
        self.useCase = useCase
        self.sessionStore = sessionStore
        self.deviceRepository = deviceAuthRepository
        self.modelContext = modelContext
        if let value = UserDefaults().string(forKey: "loginEmail") ,let value2 = UserDefaults().string(forKey: "loginPass"){
            self.email = value
            self.password = value2
        }
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
        //Auth Request
        do {
            let loginResponse = try await useCase.authenticateUser(
                email: trimmedEmail,
                password: password
            )
           //get devices List
            let devices = try await deviceRepository.fetchDevices(parameter: loginResponse.id!)
                    print("Successfully fetched \(devices.count) devices for user.")
            //TODO: check device esist here
            
            
            self.sessionStore.authData = loginResponse
            self.sessionStore.deviceList = devices
            //check devices exist
            let localRepository = LocalAuthSessionRepository(modelContext: modelContext)
            try localRepository.saveOrUpdateSession(from: loginResponse)
            
            UserDefaults.standard.set(email, forKey: "loginEmail")
            UserDefaults.standard.set(password, forKey: "loginPass")
            
            //TODO: Check device exist here
            self.isLoggedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    //Helping Private Func
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
    
    private func IsRegisteredDevice(devices:[DeviceDTO], authResponse:AuthResponseDTO, ) -> Bool{
        let deviceId = getDeviceIdFromKC()
        guard devices.contains(where: { $0.id == deviceId }) else {
            // |--> First Time logged In on this device
            guard authResponse.subscription == "Free" && authResponse.numberOfDevices! >= 2 || authResponse.subscription == "Pro" && authResponse.numberOfDevices! >= 5 else{
                //save devices devies here in Swift Data
                //TODO: Navigate to Linked Devices here
                self.isLinkedDevices = true
                return false
            }
            //Save Account here first in Swift Data
            //Add device here and navigate to Login Screen
//            call APi Here 
            return false
        }
        //Save trusted devices to JSON
        //ALready Saved Device
        return true
    }
    
    private func getDeviceIdFromKC()->String{
        Task {
            guard let deviceId = await useCase.getIdFromKC(key: "flKey") else{
                // call register device id here API
                let deviceId = try await useCase.createUserId(parameter: "userID")
                await useCase.saveToKeychain(value: deviceId, key: "flKey")
                return deviceId
            }
            return deviceId
        }
        
        
        return ""
    }
    
    @discardableResult
    func getSwiftData() -> UserSessionModel?{
        isLoading = true
        defer{
            isLoading = false
        }
       let localData = LocalAuthSessionRepository(modelContext: modelContext)
        do{
            if let fetchedUserData = try localData.fetchSessionByEmail(email: email){
                sessionStore.authData = AuthResponseDTO(message: "", errorCode: 0, id: fetchedUserData.userId, email: fetchedUserData.email, publicKey: fetchedUserData.publicKey, privateKey: fetchedUserData.privateKey, privateKeyIter: fetchedUserData.privateKeyIter, privateKeySalt: fetchedUserData.privateKeySalt, passwordIter: fetchedUserData.passwordIter, passwordSalt: fetchedUserData.passwordSalt, defaultCloud: fetchedUserData.defaultCloud, numberOfDevices: fetchedUserData.numberOfDevices, serverCurrentDate: fetchedUserData.serverCurrentDate, subscription: fetchedUserData.subscription, subscriptionDetails: SubscriptionDetailsDTO(platform: (fetchedUserData.subscriptionDetails!.platform), platformDetails: PlatformDetailsDTO(purchaseDate: fetchedUserData.subscriptionDetails?.purchaseDate, expiryDate: fetchedUserData.subscriptionDetails?.expiryDate!, cardExpiryDate: fetchedUserData.subscriptionDetails?.cardExpiryDate!, cardLastFourDigits: fetchedUserData.subscriptionDetails?.cardLastFourDigits!, activationKey: fetchedUserData.subscriptionDetails?.activationKey!)))
                print("Fetched User Data from Local DB == \(String(describing: fetchedUserData.email))")
                return fetchedUserData
            } else {
                self.errorMessage = "Login Failed"
                return nil
            }
            
            
          
//            Task{
//                guard await useCase.isValidPassword(password: password, authInfo: sessionStore.authData!) else {
//                    return
//                }
//                
//            }
            
          
            //TODO: STart From Here (TAHA)

        }catch{
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
