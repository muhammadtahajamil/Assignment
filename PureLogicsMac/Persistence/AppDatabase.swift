import Foundation
import GRDB

struct AppDatabase: Sendable {
    private let writer: any DatabaseWriter

    init(writer: any DatabaseWriter) throws {
        self.writer = writer
        try Self.migrator.migrate(writer)
    }

    static func makeDefault() -> AppDatabase {
        do {
            let directory = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appending(path: "PureLogicsMac", directoryHint: .isDirectory)

            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appending(path: "users.sqlite")
            return try AppDatabase(writer: DatabaseQueue(path: url.path(percentEncoded: false)))
        } catch {
            return try! AppDatabase(writer: DatabaseQueue())
        }
    }

    func fetchUsers() async throws -> [UserRecord] {
        try await writer.read { db in
            try UserRecord
                .order(Column("lastName"), Column("firstName"))
                .fetchAll(db)
        }
    }

    func saveUsers(_ users: [UserRecord]) async throws {
        try await writer.write { db in
            for user in users {
                try user.save(db)
            }
        }
    }

    private static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createUsers") { db in
            try db.create(table: "users", ifNotExists: true) { table in
                table.column("id", .integer).primaryKey()
                table.column("firstName", .text).notNull()
                table.column("lastName", .text).notNull()
                table.column("maidenName", .text)
                table.column("age", .integer).notNull()
                table.column("gender", .text).notNull()
                table.column("email", .text).notNull()
                table.column("phone", .text).notNull()
                table.column("username", .text).notNull()
                table.column("image", .text).notNull()
                table.column("companyTitle", .text)
                table.column("companyDepartment", .text)
                table.column("companyName", .text)
            }
        }
        return migrator
    }
}
