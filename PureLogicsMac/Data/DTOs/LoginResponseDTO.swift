import Foundation

struct LoginResponseDTO: Decodable, Sendable {
    let userId: String
    let name: String
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case name
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}
