//
//  SignInView.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(UserSessionStore.self) private var sessionStore
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        SignInStoryboardContent(
            sessionStore: sessionStore, modelCotext: modelContext
            )
    }
}

private struct SignInStoryboardContent: View {
    @Environment(AuthNavigationStore.self) private var authNavigation

    private let baseSize = CGSize(width: 800, height: 626)

    @State private var loginViewModel: LoginViewModel

    init(sessionStore: UserSessionStore, modelCotext: ModelContext) {
        let apiClient = DefaultAPIClient(environment: .development)
        let authRemoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
        let authRepository = DefaultAuthRepository(remoteDataSource: authRemoteDataSource)
        let loginUseCase = LoginUseCase(repository: authRepository)

//        _loginViewModel = State(
//            wrappedValue: LoginViewModel(
//                useCase: loginUseCase,
//                sessionStore: sessionStore,
//                deviceAuthRepository: DefaultDeviceRepository(),
//                modelContext: modelContext)
        
        _loginViewModel = State(wrappedValue: LoginViewModel(
            useCase: loginUseCase,
            sessionStore: sessionStore,
            deviceAuthRepository: DefaultDeviceRepository(),
            modelContext: modelCotext)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / baseSize.width, proxy.size.height / baseSize.height)

            storyboardLayout
                .frame(width: baseSize.width, height: baseSize.height)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(
                    width: baseSize.width * scale,
                    height: baseSize.height * scale,
                    alignment: .topLeading
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(minWidth: baseSize.width, minHeight: baseSize.height)
    }

    private var storyboardLayout: some View {
        ZStack(alignment: .topLeading) {
            Image(.signInBackGroung)
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height)

            topNavigation
            signInForm

            if loginViewModel.isLoading {
                loadingOverlay
            }
        }
    }

    private var topNavigation: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 6) {
                Image("ic_round-home")
                    .resizable()
                    .frame(width: 26, height: 26)

                Text("Main Features")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textColor)
            }
            .frame(width: 120, height: 26, alignment: .leading)
            .position(x: 70, y: 107)

            Button("Version 10.1.1") {}
                .buttonStyle(UnderlineTextButtonStyle(color: .white, font: .system(size: 13)))
                .frame(width: 87, height: 16, alignment: .leading)
                .position(x: 170.5, y: 69)

            Text("Sign in")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 48, height: 17, alignment: .leading)
                .position(x: 215, y: 103.5)

            Button {
                print("Check updates tapped")
            } label: {
                HStack(spacing: 4) {
                    Image("upgrade icon 1")
                        .resizable()
                        .frame(width: 17, height: 18)

                    Text("Check Updates")
                        .font(.system(size: 13))
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .frame(width: 116, height: 24)
            .position(x: 477, y: 104)

            HStack(spacing: 6) {
                Image("features 1 1")
                    .resizable()
                    .frame(width: 18, height: 20)

                Text("Additional Features")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textColor)
            }
            .frame(width: 145, height: 20, alignment: .leading)
            .position(x: 629.5, y: 107)
        }
    }

    private var signInForm: some View {
        ZStack(alignment: .topLeading) {
            Text("Sign in")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(textColor)
                .frame(width: 67, height: 21, alignment: .leading)
                .position(x: 231.5, y: 142.5)

            Text("Enter Email")
                .font(.system(size: 14))
                .foregroundStyle(textColor)
                .frame(width: 77, height: 17, alignment: .leading)
                .position(x: 236.5, y: 190.5)

            TextField("", text: $loginViewModel.email)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
                .frame(width: 320, height: 30)
                .position(x: 357, y: 218)

            Text("Password")
                .font(.system(size: 14))
                .foregroundStyle(textColor)
                .frame(width: 67, height: 17, alignment: .leading)
                .position(x: 231.5, y: 265.5)

            passwordField
                .frame(width: 320, height: 30)
                .position(x: 357, y: 293)

            if let errorMessage = loginViewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .lineLimit(1)
                    .frame(width: 220, height: 17, alignment: .trailing)
                    .position(x: 405, y: 320.5)
                    
            }
                

            Button {
                Task {
                    await loginViewModel.loginButtonTapped()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(signInButtonColor)

                    if loginViewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Sign in")
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(loginViewModel.isLoading)
            .frame(width: 196, height: 40)
            .position(x: 360, y: 372)
            .onChange(of: loginViewModel.errorMessage) { oldValue, newValue in
                guard newValue == NetworkError.noInternetConnection.localizedDescription else {
                    return
                }
                loginViewModel.getSwiftData()
            }

            HStack(spacing: 2) {
                Text("New User?")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)

                Button("Create Account") {
                    withAnimation(.smooth) {
                        authNavigation.showSignUp()
                    }
                }
                .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 13, weight: .semibold)))
            }
            .frame(width: 170, height: 16)
            .position(x: 368, y: 424)

            HStack(spacing: 3) {
                Text("Forgot Password?")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)

                Button("Reset Your Account") {
                    print("Reset account tapped")
                }
                .buttonStyle(UnderlineTextButtonStyle(color: .red, font: .system(size: 13, weight: .semibold)))
            }
            .frame(width: 240, height: 16)
            .position(x: 372, y: 450)
        }
    }

    private var passwordField: some View {
        ZStack(alignment: .trailing) {
            passwordInput

            Button {
                loginViewModel.isPasswordVisible.toggle()
            } label: {
                Image(.keyboard)
                    .resizable()
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 2)
            .opacity(0)
        }
    }

    @ViewBuilder
    private var passwordInput: some View {
        if loginViewModel.isPasswordVisible {
            TextField("", text: $loginViewModel.password)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
        } else {
            SecureField("", text: $loginViewModel.password)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.18))

            ProgressView()
                .controlSize(.large)
                .frame(width: 50, height: 50)
        }
        .frame(width: 362, height: 429)
        .position(x: 360, y: 332.5)
    }

    private var textColor: Color {
        Color(red: 0.333, green: 0.333, blue: 0.333)
    }

    private var linkBlue: Color {
        Color(red: 0.01, green: 0.26, blue: 0.52)
    }

    private var signInButtonColor: Color {
        Color(red: 0.035, green: 0.588, blue: 0.973)
    }
}

private struct UnderlineTextButtonStyle: ButtonStyle {
    let color: Color
    let font: Font

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(color.opacity(configuration.isPressed ? 0.7 : 1))
            .underline()
            .contentShape(Rectangle())
    }
}

#Preview("Sign In Screen", traits: .fixedLayout(width: 840, height: 626)) {
    SignInView()
        .frame(width: 840, height: 626)
        .environment(UserSessionStore())
        .environment(AuthNavigationStore())
}

/*
 //Story boards
 1.Signup View Controller
 2.
 */
