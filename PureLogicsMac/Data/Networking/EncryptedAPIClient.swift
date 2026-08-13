import Foundation

protocol APIClient: Sendable {
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
            print("response = \(decryptedResponse)")
            
            return decryptedResponse
            
        } catch let error as NetworkError {
            throw error
            
        } catch let error as APIDecryptionError {
            throw error
            
        } catch is URLError {
            throw NetworkError.noInternetConnection
        }
        catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func requestDecodable<T: Decodable>(
        _ type: T.Type,
        endpoint: any APIEndpoint
    ) async throws -> T {
        let decryptedString = try await requestDecryptedString(endpoint: endpoint)
        print("Decrypted String :",decryptedString)
        guard let data = decryptedString.data(using: .utf8) else {
            throw NetworkError.invalidUTF8Response
        }
        //message error
        if let errorDTO = try? JSONDecoder().decode(AuthResponseDTOError.self, from: data){
                throw APIError.map(code: errorDTO.errorCode, message: errorDTO.message)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
