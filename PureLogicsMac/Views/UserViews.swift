import SwiftUI

struct UserListView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @EnvironmentObject private var userStore: UserStore
    @State private var searchText = ""
    @State private var sortOrder = [KeyPathComparator(\UserRecord.lastName)]

    private var filteredUsers: [UserRecord] {
        let searched: [UserRecord]
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searched = userStore.users
        } else {
            let query = searchText.localizedLowercase
            searched = userStore.users.filter { $0.searchableText.contains(query) }
        }
        return searched.sorted(using: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            statusBanner
            Table(filteredUsers, selection: $userStore.selectedUserID, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.displayName)
                TableColumn("Email", value: \.email)
                TableColumn("Age") { user in
                    Text("\(user.age)")
                        .monospacedDigit()
                }
                .width(50)
                TableColumn("Company", value: \.companyName.unwrapped)
                TableColumn("Role", value: \.companyTitle.unwrapped)
            }
            .onChange(of: userStore.selectedUserID) { _, id in
                guard let id else { return }
                navigation.usersPath.append(UsersDestination.detail(id))
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Users")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task { await userStore.retry() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }

                Button {
                    if let id = userStore.selectedUserID {
                        navigation.usersPath.append(UsersDestination.activity(id))
                    }
                } label: {
                    Label("User Activity", systemImage: "waveform.path.ecg")
                }
                .disabled(userStore.selectedUserID == nil)
            }
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch userStore.state {
        case .loading where userStore.users.isEmpty:
            ProgressView("Loading users...")
                .frame(maxWidth: .infinity, minHeight: 52)
        case .failed(let message):
            ErrorBanner(message: message) {
                Task { await userStore.retry() }
            }
        case .offline(let message):
            ErrorBanner(message: message) {
                Task { await userStore.retry() }
            }
        default:
            EmptyView()
        }
    }
}

struct UserDetailView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @EnvironmentObject private var userStore: UserStore
    let userID: UserRecord.ID

    var body: some View {
        Group {
            if let user = userStore.user(id: userID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: user.image)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.secondary)
                                default:
                                    ProgressView()
                                }
                            }
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.displayName)
                                    .font(.largeTitle.bold())
                                Text(user.companyTitle ?? "No role provided")
                                    .foregroundStyle(.secondary)
                                Text(user.companyName ?? "No company provided")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        DetailGrid(user: user)

                        Button {
                            navigation.usersPath.append(UsersDestination.activity(user.id))
                        } label: {
                            Label("Open Activity", systemImage: "waveform.path.ecg")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(28)
                    .frame(maxWidth: 860, alignment: .leading)
                }
            } else {
                ContentUnavailableView("User Not Found", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
        .navigationTitle("User Details")
    }
}

struct UserActivityView: View {
    @EnvironmentObject private var userStore: UserStore
    let userID: UserRecord.ID

    var body: some View {
        Group {
            if let user = userStore.user(id: userID) {
                VStack(alignment: .leading, spacing: 16) {
                    Header(title: "User Activity", subtitle: user.displayName)
                    ActivityRow(title: "Profile opened", detail: "Selection is persisted while switching between sidebar sections.")
                    ActivityRow(title: "Cached locally", detail: "User \(user.id) is available from GRDB for offline viewing.")
                    ActivityRow(title: "Network source", detail: "Record originated from https://dummyjson.com/users.")
                    Spacer()
                }
                .padding(28)
            } else {
                ContentUnavailableView("User Not Found", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
        .navigationTitle("User Activity")
    }
}

struct DetailGrid: View {
    let user: UserRecord

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
            row("Email", user.email)
            row("Phone", user.phone)
            row("Username", user.username)
            row("Age", "\(user.age)")
            row("Gender", user.gender.capitalized)
            row("Department", user.companyDepartment ?? "Not provided")
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }

    private func row(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
        }
    }
}

struct ErrorBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .lineLimit(2)
            Spacer()
            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private extension Optional where Wrapped == String {
    var unwrapped: String {
        self ?? ""
    }
}
