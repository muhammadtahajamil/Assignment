//
//  loginView.swift
//  PureLogicsMac
//
//  Created by Apple on 14/07/2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isOffline: Bool
    
    @State private var loginViewModel : LoginViewModel
    let deviceRepository = DefaultDeviceRepository()
    
    init(isLoggedIn: Binding<Bool>, isOffline: Binding<Bool>, sessionStore: UserSessionStore) {
        self._isLoggedIn = isLoggedIn
        self._isOffline = isOffline
        
        let apiClient = DefaultAPIClient(
                  environment: .development
              )

              let authRemoteDataSource = DefaultAuthRemoteDataSource(
                  apiClient: apiClient
              )

              let authRepository = DefaultAuthRepository(
                  remoteDataSource: authRemoteDataSource
              )
            
              let loginUseCase = LoginUseCase(
                repository: authRepository
              )

              self._loginViewModel = State(wrappedValue: LoginViewModel(
                useCase: loginUseCase, sessionStore: sessionStore, deviceAuthRepository: deviceRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Login to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 16) {
                    
                    TextField("Email", text: $loginViewModel.email)
                        
                        .autocorrectionDisabled()
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        if loginViewModel.isPasswordVisible {
                            TextField("Password", text: $loginViewModel.password)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("Password", text: $loginViewModel.password)
                        }
                        
                        Button {
                            loginViewModel.isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: loginViewModel.isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let errorMessage = loginViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    Task{
                        await loginViewModel.loginButtonTapped()
                    }
                    
                } label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    print("Forgot password tapped")
                } label: {
                    Text("Forgot Password?")
                        .font(.subheadline)
                }
                
                Spacer()
                
                HStack {
                    Text("Don’t have an account?")
                        .foregroundStyle(.secondary)
                    
                    Button {
                        print("Sign up tapped")
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 50)
                .font(.subheadline)
            }
            .padding(.horizontal, 24)
            .navigationTitle("Login")
        }
        .onChange(of: [loginViewModel.isLoggedIn, loginViewModel.isOffline]) { oldValue, newValue in
            if newValue[0] {
                isLoggedIn = true
            }
            if newValue[1]{
                isOffline = true
            }
        }
    }
}

struct HomeView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Login successful.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Home")
    }
}


