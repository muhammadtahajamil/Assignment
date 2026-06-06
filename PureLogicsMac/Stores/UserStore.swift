import Foundation

struct UserRepository: Sendable {
    let apiClient: any UserAPIClient
    let database: AppDatabase

    func cachedUsers() async throws -> [UserRecord] {
        try await database.fetchUsers()
    }

    func refreshUsers() async throws -> [UserRecord] {
        let records = try await apiClient.fetchUsers().map(UserRecord.init(apiUser:))
        try await database.saveUsers(records)
        return records
    }
}

@MainActor
final class UserStore: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
        case offline(String)
    }

    @Published private(set) var users: [UserRecord] = []
    @Published private(set) var state: LoadState = .idle
    @Published var selectedUserID: UserRecord.ID?

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let cached = try await repository.cachedUsers()
            if !cached.isEmpty {
                users = cached
                state = .loaded
            }

            let refreshed = try await repository.refreshUsers()
            users = refreshed
            state = .loaded
        } catch {
            if users.isEmpty {
                state = .failed(error.localizedDescription)
            } else {
                state = .offline("Showing cached users. Refresh failed: \(error.localizedDescription)")
            }
        }
    }

    func retry() async {
        await load()
    }

    func user(id: UserRecord.ID?) -> UserRecord? {
        guard let id else { return nil }
        return users.first { $0.id == id }
    }
}
