import Foundation

@objc class VaultManager : NSObject {
    @objc nonisolated(unsafe) static var arrVaultFiles = [VaultFile]()
    
    @objc static func initVaultFiles() {
        arrVaultFiles.removeAll()
        
        let arrVaultInfos: [VaultInfo] = VaultInfoManager.getVaultInfo()
        
        for vaultInfo in arrVaultInfos {
            let vaultFile = VaultFile(vaultInfo: vaultInfo)
            arrVaultFiles.append(vaultFile)
        }
    }
    
    @objc static func saveVaultFiles() {
        var arrVaultInfos = [VaultInfo]()
        let vaultXmlParser = VaultXmlParser()
        
        for vaultFile in arrVaultFiles {
            let header = vaultXmlParser.getHeaderXml(fileEncInfo: vaultFile.fileEncInfo)
            let vaultInfo = VaultInfo(filename: vaultFile.fileName, headerInfo: header)
            arrVaultInfos.append(vaultInfo)
        }
        
        VaultInfoManager.setVaultInfo(arrVaultInfos: arrVaultInfos)
    }
    
    @objc static func addVaultFile(vaultFile: VaultFile) -> Bool {
        if vaultFile == nil {
            return false
        }
        
        for vaultFileItem in arrVaultFiles {
            if vaultFile.fileName == vaultFileItem.fileName {
                return false
            }
        }
        
        arrVaultFiles.append(vaultFile)
        
        // save to file
        saveVaultFiles()
        
        return true
    }
    
    @objc static func removeVaultFile(fileName: String) -> Bool {
        if fileName.isEmpty {
            return false
        }
        
        // check if already exist
        for i in 0..<arrVaultFiles.count {
            if arrVaultFiles[i].fileName == fileName {
                arrVaultFiles.remove(at: i)
                
                saveVaultFiles()
                return true
            }
        }
        
        return false
    }
    
    @objc static func updateVaultFile(vaultFile: VaultFile) -> Bool {
        if vaultFile == nil {
            return false
        }
        
        // update if alredy exist
        for i in 0..<arrVaultFiles.count {
            if vaultFile.fileName == arrVaultFiles[i].fileName {
                arrVaultFiles[i] = vaultFile
                
                saveVaultFiles()
                return true
            }
        }
        
        // add new
        arrVaultFiles.append(vaultFile)
        saveVaultFiles()
        
        return true
    }
    
    @objc static func getVaultFile(filePath: String) -> VaultFile?{
        if filePath.isEmpty {
            return nil
        }
        
        for vaultFileItem in arrVaultFiles {
            if filePath == vaultFileItem.fileName {
                return vaultFileItem
            }
        }
        
        return nil
    }
    
    static func removeAll() {
        arrVaultFiles.removeAll()
        
        saveVaultFiles()
    }
    
}
