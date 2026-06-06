import SwiftUI

struct DashboardOverviewView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @EnvironmentObject private var userStore: UserStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Header(title: "Overview", subtitle: "Application health, cached data, and recent processing status.")

            HStack(spacing: 12) {
                MetricCard(title: "Users Cached", value: "\(userStore.users.count)", systemImage: "person.crop.rectangle.stack")
                MetricCard(title: "Data Source", value: dataSourceLabel, systemImage: "externaldrive.connected.to.line.below")
                MetricCard(title: "Navigation", value: "Stateful", systemImage: "point.3.connected.trianglepath.dotted")
            }

            Button {
                navigation.dashboardPath.append(DashboardDestination.statistics)
            } label: {
                Label("Open Statistics", systemImage: "chart.xyaxis.line")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(28)
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    navigation.dashboardPath.append(DashboardDestination.statistics)
                } label: {
                    Label("Statistics", systemImage: "chart.bar")
                }
                Button {
                    navigation.dashboardPath.append(DashboardDestination.activity)
                } label: {
                    Label("Activity", systemImage: "clock.arrow.circlepath")
                }
            }
        }
    }

    private var dataSourceLabel: String {
        switch userStore.state {
        case .offline: "Offline"
        case .failed: "Error"
        case .loading: "Loading"
        default: "Ready"
        }
    }
}

struct DashboardStatisticsView: View {
    @EnvironmentObject private var userStore: UserStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Header(title: "Statistics", subtitle: "Small aggregate view derived from the persisted user dataset.")
            HStack(spacing: 12) {
                MetricCard(title: "Average Age", value: averageAge, systemImage: "number")
                MetricCard(title: "Companies", value: "\(companyCount)", systemImage: "building.2")
                MetricCard(title: "Domains", value: "\(emailDomainCount)", systemImage: "at")
            }
            GenderBreakdown(users: userStore.users)
            Spacer()
        }
        .padding(28)
        .navigationTitle("Statistics")
    }

    private var averageAge: String {
        guard !userStore.users.isEmpty else { return "0" }
        let total = userStore.users.reduce(0) { $0 + $1.age }
        return String(format: "%.1f", Double(total) / Double(userStore.users.count))
    }

    private var companyCount: Int {
        Set(userStore.users.compactMap(\.companyName)).count
    }

    private var emailDomainCount: Int {
        Set(userStore.users.compactMap { $0.email.split(separator: "@").last.map(String.init) }).count
    }
}

struct DashboardActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Header(title: "Activity", subtitle: "Recent app events surfaced as a lightweight operational timeline.")
            ActivityRow(title: "Navigation stacks", detail: "Each sidebar section owns an independent NavigationPath.")
            ActivityRow(title: "Network refresh", detail: "Users load from cache first, then refresh through async URLSession.")
            ActivityRow(title: "File hashing", detail: "MD5 uses chunked FileHandle reads with cancellation and progress.")
            Spacer()
        }
        .padding(28)
        .navigationTitle("Activity")
    }
}

struct Header: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.bold())
            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
            Text(value)
                .font(.title.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct GenderBreakdown: View {
    let users: [UserRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender Breakdown")
                .font(.headline)
            ForEach(rows, id: \.0) { label, count in
                HStack {
                    Text(label.capitalized)
                    Spacer()
                    Text("\(count)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                Divider()
            }
        }
        .padding(16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
    }

    private var rows: [(String, Int)] {
        Dictionary(grouping: users, by: \.gender)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.0 < $1.0 }
    }
}

struct ActivityRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
