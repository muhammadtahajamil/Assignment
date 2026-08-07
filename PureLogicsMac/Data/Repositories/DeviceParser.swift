import Foundation

struct DeviceParser {
    
    /// Parses custom delimited string: "id;name;platform;~id;name;platform;~"
    static func parseDevices(from rawString: String) -> [DeviceDTO] {
        let entries = rawString.split(separator: "~", omittingEmptySubsequences: true)
        
        return entries.compactMap { entry in
            let fields = entry.split(separator: ";", omittingEmptySubsequences: true)
            guard fields.count >= 3 else { return nil }
            
            return DeviceDTO(
                id: String(fields[0]),
                name: String(fields[1]),
                platform: String(fields[2])
            )
        }
    }
}
