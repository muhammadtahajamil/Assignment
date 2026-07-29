//
//  APIEnvironment.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//



import Foundation

struct UserSession: Sendable {
    let userId: String
    let name: String
    let accessToken: String
    let refreshToken: String
}

struct UserAuthInfo: Sendable {
    let id: String
    let email: String
    let publicKey: String
    let privateKey: String
    let subscription: String
    let numberOfDevices: Int
    let serverCurrentDate: String
}

enum APIEnvironment {
    case development
    case staging
    case production

    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev.newsoftwares.net/fl10/v2/")!

        case .staging:
            return URL(string: "https://staging-api.example.com")!

        case .production:
            return URL(string: "https://api.newsoftwares.net/fl10/v2/")!
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }

    func bodyData() throws -> Data?
}

extension APIEndpoint {
    var headers: [String: String] {
        return [:]
    }

    var queryItems: [URLQueryItem] {
        return []
    }

    func bodyData() throws -> Data? {
        return nil
    }
}

extension APIEndpoint {
    var isEncrypted: Bool {
        return true // Default all API endpoints to encrypted
    }
}

enum AuthEndpoint: APIEndpoint {

    case login(LoginRequestDTO)
    case readAuth(parameter: String)
    case logout
    case refreshToken(token: String)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"

        case .readAuth:
            return "/user_login.php"

        case .logout:
            return "/auth/logout"

        case .refreshToken:
            return "/auth/refresh-token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post

        case .readAuth:
            return .put

        case .logout:
            return .post

        case .refreshToken:
            return .post
        }
    }

    var headers: [String: String] {
        switch self {
        case .readAuth:
            return [
                "Content-Type": "text/plain; charset=utf-8",
                "Accept": "text/plain"
            ]
        default:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }

    func bodyData() throws -> Data? {
        switch self {
        case .login(let request):
            return try JSONEncoder().encode(request)

        case .readAuth(let parameter):
            return Data(parameter.utf8)

        case .logout:
            return nil

        case .refreshToken(let token):
            let body = RefreshTokenRequestDTO(refreshToken: token)
            return try JSONEncoder().encode(body)
        }
    }
}


enum URLRequestBuilderError: LocalizedError {
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Unable to build request URL."
        }
    }
}

final class URLRequestBuilder :Sendable{

    private let environment: APIEnvironment

    init(environment: APIEnvironment) {
        self.environment = environment
    }

    func buildRequest(for endpoint: any APIEndpoint) throws -> URLRequest {
        let url = try buildURL(for: endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try endpoint.bodyData()
        request.timeoutInterval = 30
        request.setValue("macOS", forHTTPHeaderField: "App-Platform")

        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func buildURL(for endpoint: any APIEndpoint) throws -> URL {
        var components = URLComponents(
            url: environment.baseURL,
            resolvingAgainstBaseURL: false
        )

        let basePath = environment.baseURL.path
        let endpointPath = endpoint.path

        if basePath.isEmpty || basePath == "/" {
            components?.path = endpointPath
        } else {
            components?.path = basePath + endpointPath
        }

        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else {
            throw URLRequestBuilderError.invalidURL
        }

        return url
    }
}
