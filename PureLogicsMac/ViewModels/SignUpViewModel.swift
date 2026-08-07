//
//  SignUpViewModel.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import Foundation
import Observation

enum PasswordStrength {
    case none
    case weak
    case medium
    case good
    case strong

    var barWidth: CGFloat {
        switch self {
        case .none: return 0
        case .weak: return 80
        case .medium: return 160
        case .good: return 240
        case .strong: return 312
        }
    }
}

@MainActor
@Observable final class SignUpViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var proCode: String = ""
    var isAgreed: Bool = false
    var isPasswordVisible: Bool = false
    var isConfirmPasswordVisible: Bool = false
    var isPurchasedProExpanded: Bool = false
    var errorMessage: String?
    var isLoading: Bool = false
    var isSignedUp: Bool = false

    private let sessionStore: UserSessionStore?

    init(sessionStore: UserSessionStore? = nil) {
        self.sessionStore = sessionStore
    }

    var isPasswordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    var passwordStrength: PasswordStrength {
        guard !password.isEmpty else { return .none }

        let length = password.count
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasSpecial = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil

        if length >= 10 && hasNumbers && hasLetters && hasSpecial {
            return .strong
        } else if length >= 8 && (hasNumbers || hasSpecial) && hasLetters {
            return .good
        } else if length >= 6 {
            return .medium
        } else {
            return .weak
        }
    }

    func signUpButtonTapped() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if let validateError = validateForm(email: trimmedEmail) {
            self.errorMessage = validateError
            return
        }

        errorMessage = nil
        isLoading = true

        // Simulate sign up process
        try? await Task.sleep(for: .seconds(1.5))

        isLoading = false
        isSignedUp = true
    }

    private func validateForm(email: String) -> String? {
        if email.isEmpty { return "Please enter your email." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        if password.isEmpty { return "Please enter your password." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        if confirmPassword.isEmpty { return "Please confirm your password." }
        if password != confirmPassword { return "Passwords do not match." }
        if !isAgreed { return "You must agree to the terms." }
        return nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
