//
//  VerifyAccountVM.swift
//  PureLogicsMac
//
//  Created by Apple on 09/08/2026.
//

import Foundation

@MainActor
@Observable final class VerifyAccountVM {
    
    
    //Variables
    var enteredPinCode: [String] = Array(repeating: "", count: 6)
    var isIncorrectPin: Bool = false
    var isLoading: Bool = false
    var timeRemaining: Int = 60
    var canResendCode: Bool = false
    var isSignedUpSuccess: Bool = false
    var doLogin: Bool = false
    var errorMessage: String?
    
    var email:String {
        sessionStore.verificationData!.email+sessionStore.verificationData!.pinCode
    }
    private let useCase: LoginUseCase
    private let sessionStore: UserSessionStore
    
    init(useCase:LoginUseCase, sessionStore: UserSessionStore) {
        self.useCase = useCase
        self.sessionStore = sessionStore
    }
    
    func test(){
        print("Varification Data : \(sessionStore.verificationData!)")
    }
    
//    func showPopUp(){
//        showPopup = true
//    }
    
    func verifyAccountButtonTapped() async {
        defer {
            isLoading = false
        }
        isLoading = true
        guard validatePin(pincode: sessionStore.verificationData!.pinCode, enteredPinCode: enteredPinCode.joined(separator: "")) else{
            self.errorMessage = APIError.invalidCredentials.localizedDescription
            return
        }
        do{
            let userId = try await useCase.createUserId(parameter: "userID")
            // create account working VerifyAccountViewController line no 200
            let createAccountResult = try await useCase.createAccount(userId: userId, email: sessionStore.verificationData!.email, proCode: "", password: sessionStore.verificationData!.password)
            print("Value == ",createAccountResult)
            //call api here
            _ = try await useCase.signUpAccount(parameter: createAccountResult)
            isSignedUpSuccess = true
        }catch{
            errorMessage = error.localizedDescription
        }
    }
    
    func signUpSuccess() async throws{
        defer {
            isLoading = false
        }
        isLoading = true
        do {
            let loginResponse = try await useCase.authenticateUser(
                email: sessionStore.verificationData!.email,
                password: sessionStore.verificationData!.password
            )
            self.sessionStore.authData = loginResponse
//            self.sessionStore.verificationData = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
    }
    private func validatePin(pincode : String, enteredPinCode : String) ->Bool {
        guard pincode == enteredPinCode else {
            return false
        }
        return true
    }
}


//Variables
