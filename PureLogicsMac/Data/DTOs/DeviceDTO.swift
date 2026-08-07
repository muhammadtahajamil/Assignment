import Foundation

struct DeviceDTO: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let platform: String
}
