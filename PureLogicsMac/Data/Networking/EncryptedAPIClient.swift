import Foundation

protocol APIClient {
    func requestDecryptedString(
        endpoint: any APIEndpoint
    ) async throws -> String
    
    func requestDecodable<T: Decodable>(
        _ type: T.Type,
        endpoint: any APIEndpoint
    ) async throws -> T
}

final class DefaultAPIClient: APIClient, Sendable {
    
    private let session: URLSession
    private let requestBuilder: URLRequestBuilder
    private let decryptor: APIResponseDecrypting
    
    init(
        environment: APIEnvironment,
        session: URLSession = .shared,
        decryptor: APIResponseDecrypting = APIResponseDecryptor()
    ) {
        self.session = session
        self.requestBuilder = URLRequestBuilder(environment: environment)
        self.decryptor = decryptor
    }
    
    func requestDecryptedString(
        endpoint: any APIEndpoint
    ) async throws -> String {
        do {
            let request = try requestBuilder.buildRequest(for: endpoint)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.invalidStatusCode(httpResponse.statusCode)
            }
            
            guard let encryptedResponse = String(data: data, encoding: .utf8) else {
                throw NetworkError.invalidUTF8Response
            }
            
            let decryptedResponse = try decryptor.decryptAPIResponse(encryptedResponse)
            let jsonData = decryptedResponse.data(using: .utf8)
            do {
                let userResponse = try JSONDecoder().decode(AuthResponseDTO.self, from: jsonData!)

            } catch {
                print("Failed to decode JSON: \(error)")
            }
            
            return decryptedResponse
            
        } catch let error as NetworkError {
            throw error
            
        } catch let error as APIDecryptionError {
            throw error
            
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func requestDecodable<T: Decodable>(
        _ type: T.Type,
        endpoint: any APIEndpoint
    ) async throws -> T {
        let decryptedString = try await requestDecryptedString(endpoint: endpoint)
        
        guard let data = decryptedString.data(using: .utf8) else {
            throw NetworkError.invalidUTF8Response
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

//final class DefaultAPIClient: APIClient {
//
//    private let session: URLSession
//    private let requestBuilder: URLRequestBuilder
//    private let decryptor: APIResponseDecrypting
//    private let encryptor: APIRequestEncrypting // <-- Inject Encryptor
//
//    init(
//        environment: APIEnvironment,
//        session: URLSession = .shared,
//        decryptor: APIResponseDecrypting = APIResponseDecryptor(),
//        encryptor: APIRequestEncrypting = APIRequestEncryptor() // <-- Default value
//    ) {
//        self.session = session
//        self.requestBuilder = URLRequestBuilder(environment: environment)
//        self.decryptor = decryptor
//        self.encryptor = encryptor
//    }
//
//    func requestDecryptedString(
//        endpoint: any APIEndpoint,
//        encryptionKey: String = "YourEncryptionKey"
//    ) async throws -> String {
//        do {
//            var request = try requestBuilder.buildRequest(for: endpoint)
//
//            // Encrypt Request Body if required
//            if endpoint.isEncrypted, let originalBody = request.httpBody {
//                let encryptedBody = try encryptor.encryptData(originalBody, key: encryptionKey)
//                request.httpBody = encryptedBody
//            }
//
//            let (data, response) = try await session.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw NetworkError.invalidResponse
//            }
//
//            guard 200...299 ~= httpResponse.statusCode else {
//                throw NetworkError.invalidStatusCode(httpResponse.statusCode)
//            }
//
//            guard let encryptedResponse = String(data: data, encoding: .utf8) else {
//                throw NetworkError.invalidUTF8Response
//            }
//
//            let decryptedResponse = try decryptor.decryptAPIResponse(encryptedResponse)
//            return decryptedResponse
//
//        } catch let error as NetworkError {
//            throw error
//        } catch let error as APIDecryptionError {
//            throw error
//        } catch let error as APIEncryptionError {
//            throw error
//        } catch {
//            throw NetworkError.requestFailed(error)
//        }
//    }
//}
