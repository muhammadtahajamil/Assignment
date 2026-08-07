import Foundation

protocol DeviceRepository: Sendable {
    func fetchDevices(parameter: String) async throws -> [DeviceDTO]
}
