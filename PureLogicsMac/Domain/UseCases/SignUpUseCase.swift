////
////  SignUpUseCase.swift
////  PureLogicsMac
////
////  Created by Apple on 07/08/2026.
////
//
//import Foundation
//
//actor SignUpUseCase: Sendable {
//    private let repository: SignUpRepository
//
//    init(repository: SignUpRepository) {
//        self.repository = repository
//    }
//
//    func execute(
//        email: String,
//        password: String,
//        proCode: String?
//    ) async throws -> UserSession {
//        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !trimmedEmail.isEmpty else {
//            throw SignUpError.emptyEmail
//        }
//
//        guard isValidEmail(trimmedEmail) else {
//            throw SignUpError.invalidEmail
//        }
//
//        guard password.count >= 6 else {
//            throw SignUpError.passwordTooShort
//        }
//
//        return try await repository.signUp(
//            email: trimmedEmail,
//            password: password,
//            proCode: proCode
//        )
//    }
//
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
//        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
//    }
//}
//
//enum SignUpError: LocalizedError {
//    case emptyEmail
//    case invalidEmail
//    case passwordTooShort
//    case passwordsDoNotMatch
//    case termsNotAgreed
//    case unknown(String)
//
//    var errorDescription: String? {
//        switch self {
//        case .emptyEmail:
//            return "Please enter your email."
//        case .invalidEmail:
//            return "Please enter a valid email address."
//        case .passwordTooShort:
//            return "Password must be at least 6 characters."
//        case .passwordsDoNotMatch:
//            return "Passwords do not match."
//        case .termsNotAgreed:
//            return "You must agree to the terms."
//        case .unknown(let message):
//            return message
//        }
//    }
//}
