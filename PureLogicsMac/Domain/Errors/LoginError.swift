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
    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "Incorrect password. Please try again."
        case .userNotExist:
            return "User Does not exist."
        case.unknowError:
            return "Something went wrong. Please try again."
        }
    }
}
