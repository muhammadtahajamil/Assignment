import Foundation

protocol UserAPIClient: Sendable {
    func fetchUsers() async throws -> [APIUser]
}

struct DummyJSONUserAPIClient: UserAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUsers() async throws -> [APIUser] {
        var components = URLComponents(string: "https://dummyjson.com/users")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "208"),
            URLQueryItem(name: "select", value: "firstName,lastName,maidenName,age,gender,email,phone,username,image,company")
        ]

        let (data, response) = try await session.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UsersResponse.self, from: data).users
    }
}
