import Foundation


//Relace single value to Array
struct DeviceDTOList: Sendable, Hashable {
    let devices: [DeviceDTO]?
}

struct DeviceDTO: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let platform: String
}
