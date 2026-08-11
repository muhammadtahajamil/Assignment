//
//  LoginError.swift
//  PureLogicsMac
//
//  Created by Apple on 29/07/2026.
//


enum LoginError: LocalizedError {
    case invalidPassword
    case userNotExist
    case unknowError
    case userAlreadyExists
    case pinCodeSentFailed
    case createUserIdFailure
    case createPasswrodFailed
    case signupError
    
    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "Incorrect password. Please try again."
        case .userNotExist:
            return "User Does not exist."
        case.unknowError:
            return "Something went wrong. Please try again."
        case .userAlreadyExists:
            return "User is already registered"
        case .pinCodeSentFailed:
            return "Failed to send pin code. Please try again."
        case .createUserIdFailure:
            return "Failed to create user ID. Please try again."
        case .createPasswrodFailed:
            return "Failed to create password. Please try again."
        case .signupError:
            return "Failed to signup. Please try again."

        }
    }
}
