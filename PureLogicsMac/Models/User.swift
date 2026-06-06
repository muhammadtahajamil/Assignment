import Foundation
import GRDB

struct UsersResponse: Decodable {
    let users: [APIUser]
}

struct APIUser: Decodable, Identifiable {
    let id: Int64
    let firstName: String
    let lastName: String
    let maidenName: String?
    let age: Int
    let gender: String
    let email: String
    let phone: String
    let username: String
    let image: String
    let company: APICompany?

    var displayName: String {
        "\(firstName) \(lastName)"
    }
}

struct APICompany: Decodable {
    let title: String?
    let department: String?
    let name: String?
}

struct UserRecord: Codable, FetchableRecord, PersistableRecord, Identifiable, Hashable {
    static let databaseTableName = "users"

    let id: Int64
    var firstName: String
    var lastName: String
    var maidenName: String?
    var age: Int
    var gender: String
    var email: String
    var phone: String
    var username: String
    var image: String
    var companyTitle: String?
    var companyDepartment: String?
    var companyName: String?

    var displayName: String {
        "\(firstName) \(lastName)"
    }

    var searchableText: String {
        [
            firstName,
            lastName,
            maidenName,
            email,
            username,
            phone,
            companyTitle,
            companyDepartment,
            companyName
        ]
            .compactMap(\.self)
            .joined(separator: " ")
            .localizedLowercase
    }

    init(apiUser: APIUser) {
        id = apiUser.id
        firstName = apiUser.firstName
        lastName = apiUser.lastName
        maidenName = apiUser.maidenName
        age = apiUser.age
        gender = apiUser.gender
        email = apiUser.email
        phone = apiUser.phone
        username = apiUser.username
        image = apiUser.image
        companyTitle = apiUser.company?.title
        companyDepartment = apiUser.company?.department
        companyName = apiUser.company?.name
    }
}
