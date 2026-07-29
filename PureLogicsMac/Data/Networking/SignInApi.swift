//
//  SignInApi.swift
//  PureLogicsMac
//
//  Created by Apple on 27/07/2026.
//

import Foundation

protocol SignInApi : Sendable {
    func fetchSignInData() async throws -> [APIUser]
}

enum AuthAPIError: LocalizedError {
    case invalidResponse
    case invalidStatusCode(Int)
    case invalidUTF8Response

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."

        case .invalidStatusCode(let code):
            return "Request failed with status code \(code)."

        case .invalidUTF8Response:
            return "Unable to read server response."
        }
    }
}


struct SiginApiResponse: SignInApi {
    func fetchSignInData() async throws -> [APIUser] {
        print("Taha")
        return []
    }
    
   
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    //
//    func fetchSignInData() async throws -> [APIUser] {
//        
//    }
    
}
