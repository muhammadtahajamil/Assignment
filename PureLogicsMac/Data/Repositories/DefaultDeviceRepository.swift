import Foundation

struct DefaultDeviceRepository: DeviceRepository {
    private let apiClient: APIClient
    private let encryptor: APIRequestEncrypting

    init(
        apiClient: APIClient = DefaultAPIClient(environment: .development),
        encryptor: APIRequestEncrypting = APIRequestEncryptor()
    ) {
        self.apiClient = apiClient
        self.encryptor = encryptor
    }

    func fetchDevices(parameter: String) async throws -> [DeviceDTO] {
        let encryptedParameter = try encryptor.encryptParameter(parameter)
        let endpoint = AuthEndpoint.checkExistingDevice(parameter: encryptedParameter)
        let rawString = try await apiClient.requestDecryptedString(endpoint: endpoint)
        print("rawString: \(rawString)")
        if let errorDTO = try? JSONDecoder().decode(AuthResponseDTOError.self, from: Data(rawString.utf8)) {
            throw APIError.map(code: errorDTO.errorCode, message: errorDTO.message)
        }
        
        return DeviceParser.parseDevices(from: rawString)
    }
}

