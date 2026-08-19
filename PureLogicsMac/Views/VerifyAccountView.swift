//
//  VerifyAccountView.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import SwiftUI

struct VerifyAccountView: View {
    
    @Environment(UserSessionStore.self) private var sessionStore
    
    var onVerifySuccess: (() -> Void)? = nil
    var onResendCode: (() -> Void)? = nil
   

    var body: some View {
        VerifyAccountStoryboardContent(
            sesionStore: sessionStore
        )
    }
}

private struct VerifyAccountStoryboardContent: View {
    
    @State private var verifyAccountVM: VerifyAccountVM
    
    private let baseSize = CGSize(width: 800, height: 626)
    init(sesionStore:UserSessionStore){
        let apiClient = DefaultAPIClient(environment: .development)
               let authRemoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
               let authRepository = DefaultAuthRepository(remoteDataSource: authRemoteDataSource)
               let loginUseCase = LoginUseCase(repository: authRepository)
        _verifyAccountVM = State(wrappedValue: VerifyAccountVM(useCase: loginUseCase, sessionStore: sesionStore))
    }
    
    var onVerifySuccess: (() -> Void)?
    var onResendCode: (() -> Void)?
    
    @FocusState private var focusedField: Int?
    

    // Countdown Timer
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .onReceive(timer) { _ in
            if verifyAccountVM.timeRemaining > 0 {
                verifyAccountVM.timeRemaining -= 1
            } else {
                verifyAccountVM.canResendCode = true
            }
        }
    }

    private var storyboardLayout: some View {
        ZStack(alignment: .topLeading) {
            Image("Sign_InBackGroung")
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height)

            topNavigation
            verifyAccountForm

            if verifyAccountVM.isLoading {
                loadingOverlay
            }
            
            if verifyAccountVM.isSignedUpSuccess {
               
                ZStack {
                    // Dimmed overlay background that blocks clicks underneath
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            verifyAccountVM.isSignedUpSuccess = false
                        }
                    // Centered Popup
                    CustomPopupView (viewModel: verifyAccountVM)
                    .padding(.trailing, 79)
                    .transition(.scale.combined(with: .opacity))
                }
                .frame(width: baseSize.width, height: baseSize.height, alignment: .center)
                .zIndex(1) // Ensures popup stays above all other layers
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

            Button("Version 10.1.1") {
                print("Button Version 10.1.1 Tapped")
            }
                .buttonStyle(UnderlineTextButtonStyle(color: .white, font: .system(size: 13)))
                .frame(width: 87, height: 16, alignment: .leading)
                .position(x: 170.5, y: 69)

            Text("Verify Account")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 99, height: 17, alignment: .leading)
                .position(x: 240.5, y: 102.5)

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

    private var verifyAccountForm: some View {
        ZStack(alignment: .topLeading) {
            Text("Verify Account")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(textColor)
                .frame(width: 128, height: 21, alignment: .leading)
                .position(x: 259, y: 140.5)

            HStack(spacing: 9) {
                Text("Email:")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                Text(verifyAccountVM.email)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .frame(width: 270, alignment: .leading)
            }
            .frame(width: 322, height: 17, alignment: .leading)
            .position(x: 356, y: 166.5)

            Text("Enter PIN Code")
                .font(.system(size: 14))
                .foregroundStyle(textColor)
                .frame(width: 103, height: 17, alignment: .leading)
                .position(x: 246.5, y: 204.5)

            pinCodeFields
                .frame(width: 328, height: 43)
                .position(x: 364, y: 239.5)

            if verifyAccountVM.isIncorrectPin {
                Text("Incorrect Pin")
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .frame(width: 82, height: 16, alignment: .trailing)
                    .position(x: 486, y: 273)
            }

            VStack(alignment: .leading, spacing: 18) {
                Text("Please check your email and enter the PIN code \nsent to you in the field above.")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                Text("For security reasons, you are required to do this \none time only!")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
            }
            .frame(width: 316, height: 86, alignment: .leading)
            .position(x: 353, y: 339)

            Button {
                Task{
                    await verifyAccountVM.verifyAccountButtonTapped()
                }
               
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(verifyButtonColor)

                    Text("Verify")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 195, height: 40)
            .position(x: 361.5, y: 422)
            .onChange(of: verifyAccountVM.isSignedUpSuccess) { oldValue, newValue in
                print("Old Value: \(oldValue),  New Value: \(newValue) ")
            }
            resendCodeSection
                .position(x: verifyAccountVM.canResendCode ? 362 : 376, y: 468.5)

            Button("Go Back") {
//                onGoBack?()
            }
            .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 14, weight: .semibold)))
            .frame(width: 60, height: 17)
            .position(x: 368, y: 521.5)
        }
    }

    private var pinCodeFields: some View {
        HStack(spacing: 20) {
            ForEach(0..<6, id: \.self) { index in
                TextField("", text: $verifyAccountVM.enteredPinCode[index])
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18))
                    .frame(width: 38, height: 43)
                    .focused($focusedField, equals: index)
                    .onChange(of: verifyAccountVM.enteredPinCode[index]) { oldValue, newValue in
                        if newValue.count > 1 {
                            verifyAccountVM.enteredPinCode[index] = String(newValue.suffix(1))
                        }
                        if !newValue.isEmpty && index < 5 {
                            focusedField = index + 1
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var resendCodeSection: some View {
        if verifyAccountVM.canResendCode {
            HStack(spacing: 2) {
                Text("You can")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                Button("Resend code") {
                    onResendCode?()
                    verifyAccountVM.timeRemaining = 60
                    verifyAccountVM.canResendCode = false
                }
                .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 14)))

                Text("Now!")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
            }
            .frame(height: 19)
        } else {
            HStack(spacing: 0) {
                Text("You can Resend Code in ")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)

                Text("\(verifyAccountVM.timeRemaining)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(textColor)

                Text(" Seconds.")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
            }
            .frame(height: 19)
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
        .frame(width: 362, height: 430)
        .position(x: 360, y: 333)
    }

    private var textColor: Color {
        Color(red: 0.333, green: 0.333, blue: 0.333)
    }

    private var linkBlue: Color {
        Color(red: 0.01, green: 0.26, blue: 0.52)
    }

    private var verifyButtonColor: Color {
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


struct CustomPopupView: View {

    @Bindable var viewModel : VerifyAccountVM
    @Environment(AuthNavigationStore.self) private var authNavigation

    var body: some View {
        VStack(spacing: 20) {

            HStack {
                Text("Popup Title")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                   viewModel.isSignedUpSuccess = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
            }

            Divider()

            Text("Your account is successfully created. Continue to proceed to Login.")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            HStack {
                Spacer()
                Button("Continue") {
                    viewModel.isSignedUpSuccess = false
                    viewModel.doLogin = true
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .onChange(of: viewModel.doLogin, { oldValue, newValue in
            print("oldValue: \(oldValue), newValue: \(newValue)")
            Task{
                do{
                    try await viewModel.signUpSuccess()
                    withAnimation(.smooth) {
                        authNavigation.showSignIn()
                    }
                }catch{
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        })
        .padding(24)
        .frame(width: 363, height: 200)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(
                    color: .black.opacity(0.8),
                    radius: 40,
                    x: 0,
                    y: 8
                )
        }
    }
}


