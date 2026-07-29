import Foundation

@objc class VaultInfoManager : NSObject {
    static let VAULTINFO_XML_FILE = "vault_info.xml"
    
    @objc static func getVaultInfo() -> [VaultInfo] {
        var arrVaultInfos = [VaultInfo]()
        do {
            let utilManager = UtilManagerC()
            if utilManager == nil {
                return []
            } else {
                var contents = utilManager!.readFile(VAULTINFO_XML_FILE)
                if contents == nil && contents!.isEmpty {
                    return []
                }
                // Shujaat: Commented following 2 lines
                //let vaultInfoXml: VaultInfoXml = VaultInfoXml()
                // arrVaultInfos = vaultInfoXml.parse(xmlBody: contents!, isFile: true)
            }
            
            return arrVaultInfos
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    @objc static func setVaultInfo(arrVaultInfos: [VaultInfo]) -> Bool {
        // Shujaat: Commented following 4 lines
//        let vaultInfoXml: VaultInfoXml = VaultInfoXml()
//        let xmlContent = vaultInfoXml.makeHeader(vaultInfos: arrVaultInfos, isFile: true)
//
//        let utilManager = UtilManagerC()
//        utilManager!.writeFile(VAULTINFO_XML_FILE, andFileContent: xmlContent)
        
        return true
    }
}
