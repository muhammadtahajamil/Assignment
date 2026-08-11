//
//  SignUpView.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import SwiftUI

struct SignUpView: View {
    @Environment(UserSessionStore.self) private var sessionStore

    var body: some View {
        SignUpStoryboardContent(sessionStore: sessionStore)
    }
}

private struct SignUpStoryboardContent: View {
    @Environment(AuthNavigationStore.self) private var authNavigation

    private let baseSize = CGSize(width: 800, height: 626)

    @State private var signUpViewModel: SignUpViewModel
    
    init(sessionStore: UserSessionStore? = nil) {
        let apiClient = DefaultAPIClient(environment: .development)
        let authRemoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
        let authRepository = DefaultAuthRepository(remoteDataSource: authRemoteDataSource)
        let authUseCase = LoginUseCase(repository: authRepository)

        _signUpViewModel = State(
            wrappedValue: SignUpViewModel(
                useCase: authUseCase,
                sessionStore: sessionStore
            )
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
            Image("Sign_InBackGroung")
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height)

            topNavigation
            signUpForm

            if signUpViewModel.isLoading {
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

            Button {
                print("Check updates tapped")
            } label: {
                HStack(spacing: 4) {
                    Image("upgrade icon 1")
                        .resizable()
                        .frame(width: 17, height: 18)

                    Text("Checking Updates")
                        .font(.system(size: 13))
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .frame(width: 135, height: 24)
            .position(x: 467.5, y: 104)

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

    private var signUpForm: some View {
        ZStack(alignment: .topLeading) {
            Text("Create Account")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(textColor)
                .frame(width: 131, height: 20, alignment: .leading)
                .position(x: 263.5, y: 140)

            formInputFields
                .frame(width: 321, height: 171)
                .position(x: 358.5, y: 250.5)

            if signUpViewModel.passwordStrength != .none {
                passwordStrengthBar
                    .position(x: 203 + signUpViewModel.passwordStrength.barWidth / 2, y: 345)
            }

            if signUpViewModel.isPasswordMismatch {
                Text("Password didn't match")
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .frame(width: 150, height: 16, alignment: .trailing)
                    .position(x: 445, y: 345)
            }

//            purchasedProSection
//                .position(x: 358.5, y: 375)

            agreementSection
                .position(x: 359, y: signUpViewModel.isPurchasedProExpanded ? 445 : 400)

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .lineLimit(1)
                    .frame(width: 321, height: 17, alignment: .trailing)
                    .position(x: 360, y: 345)
                //signUpViewModel.isPurchasedProExpanded ? 475 : 425
            }

            Button {
                Task {
                    await signUpViewModel.signUpButtonTapped()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(signUpButtonColor)

                    if signUpViewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Sign Up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(signUpViewModel.isLoading)
            .frame(width: 196, height: 40)
            .position(x: 361, y: signUpViewModel.isPurchasedProExpanded ? 505 : 455)
            .onChange(of: signUpViewModel.isPinCodeSent) { oldValue, newValue in
                    guard newValue else {
                            return
                    }
                withAnimation(.smooth) {
                    authNavigation.showVerifyAccount()
                }
                }
            HStack(spacing: 2) {
                Text("Already a User?")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)

                Button("Sign in") {
                    withAnimation(.smooth) {
                        authNavigation.showSignIn()
                    }
                }
                .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 14, weight: .semibold)))
            }
            .frame(width: 170, height: 17)
            .position(x: 360, y: 520)
        }
    }

    private var formInputFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Enter Email")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                TextField("", text: $signUpViewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .frame(height: 30)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Create Password")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                passwordInputField(
                    text: $signUpViewModel.password,
                    isVisible: $signUpViewModel.isPasswordVisible
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Confirm Password")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                passwordInputField(
                    text: $signUpViewModel.confirmPassword,
                    isVisible: $signUpViewModel.isConfirmPasswordVisible
                )
            }
        }
    }

    private func passwordInputField(text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        ZStack(alignment: .trailing) {
            if isVisible.wrappedValue {
                TextField("", text: text)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .frame(height: 30)
            } else {
                SecureField("", text: text)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .frame(height: 30)
            }

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image("Keyboard")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
        }
    }

    private var passwordStrengthBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(passwordStrengthColor)
            .frame(width: signUpViewModel.passwordStrength.barWidth, height: 4)
    }

    private var passwordStrengthColor: Color {
        switch signUpViewModel.passwordStrength {
        case .none: return .clear
        case .weak: return Color(red: 0.9, green: 0.22, blue: 0.21)
        case .medium: return Color(red: 0.98, green: 0.55, blue: 0.0)
        case .good: return Color(red: 0.99, green: 0.85, blue: 0.21)
        case .strong: return Color(red: 0.3, green: 0.73, blue: 0.28)
        }
    }

    private var purchasedProSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation {
                    signUpViewModel.isPurchasedProExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: signUpViewModel.isPurchasedProExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))

                    Text("Purchased Pro?")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(dropDownBlue)
            }
            .buttonStyle(.plain)

            if signUpViewModel.isPurchasedProExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Purchased for someone or yourself? Enter Pro Code:")
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)

                    TextField("", text: $signUpViewModel.proCode)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13))
                        .frame(height: 30)
                }
            }
        }
        .frame(width: 323, alignment: .leading)
    }

    private var agreementSection: some View {
        HStack(spacing: 4) {
            Toggle(isOn: $signUpViewModel.isAgreed) {
                Text("I agree to")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)
            }
            .toggleStyle(.checkbox)

            Text("Not forget this password")
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 0.999, green: 0.23, blue: 0.19))

            Button("Why?") {
                print("Why popover tapped")
            }
            .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 14, weight: .semibold)))
        }
        .frame(width: 320, height: 17, alignment: .leading)
    }

    private var loadingOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.18))

            ProgressView()
                .controlSize(.large)
                .frame(width: 50, height: 50)
        }
        .frame(width: 362, height: 430)
        .position(x: 360, y: 332.5)
    }

    private var textColor: Color {
        Color(red: 0.333, green: 0.333, blue: 0.333)
    }

    private var linkBlue: Color {
        Color(red: 0.01, green: 0.26, blue: 0.52)
    }

    private var dropDownBlue: Color {
        Color(red: 0.129, green: 0.431, blue: 0.741)
    }

    private var signUpButtonColor: Color {
        Color(red: 0.078, green: 0.729, blue: 0.027)
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

#Preview("Sign Up Screen", traits: .fixedLayout(width: 840, height: 626)) {
    SignUpView()
        .frame(width: 840, height: 626)
        .environment(UserSessionStore())
        .environment(AuthNavigationStore())
}
