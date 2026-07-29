import Foundation

@objc class VaultFile : NSObject{
  
    static let IDENTIFIER = "FL10                "; // Total 20 characters [Don't remove spaces!]
    static let IDENTIFIER_LEN = 20;                 // Before was: 7
    static let IDENTIFIER_POS = 0;                  // Indicating the position of IDENTIFIER in the header.
    static let HEADER_XML_POS = 20;                 // Before was: KEYS_POS 7         // 2 bytes integer indicating where header XML starts.
    static let HEADER_XML_LEN = 22;                 // Before was: KEYS_LEN_POS 9     // 2 bytes integer indicating the total length of the header XML, including <header>...</header> tags & anything within it.
    static let FILE_CONTENT_POS = 24;               // Before was: DATA_POS 11        // 2 bytes integer storing file content (ciphertext) position.
    static let DEFAULT_HEADER_XML_POS = 40;         // Before was: DEFAULT_KEYS_POS   // Header Meta Data (40) = IDENTIFIER_LEN (20) + HEADER_XML_POS (2) + HEADER_XML_LEN (2) + FILE_CONTENT_POS (2) + RESERVED.
    static let DEFAULT_HEADER_SIZE = 8192;
    @objc static let DEFAULT_FILE_CONTENT_POS = DEFAULT_HEADER_SIZE;  // Before was: DEFAULT_DATA_POS
    static let MAX_HEADER_XML_SIZE = (DEFAULT_HEADER_SIZE - DEFAULT_HEADER_XML_POS);

    @objc static let AES_KEY_LEN = 32;
    @objc static let FOLDER_KEY = "folder_key.fl10";
       
    @objc var fileName = ""
    @objc var fileEncInfo: FileEncInfo? = nil
    
    @objc init(fileName: String){
        self.fileName = fileName;
    }
        
    @objc init(account: Account, fileName: String) {
        fileEncInfo = FileEncInfo(account: account)
        self.fileName = fileName
    }
    
    @objc init(vaultInfo: VaultInfo) {
        let vaultXmlParser = VaultXmlParser()
        let fileEncInfo = vaultXmlParser.parse(xmlBody: vaultInfo.headerInfo)
        self.fileName = vaultInfo.filename
        self.fileEncInfo = fileEncInfo
    }
    
    @objc func isEncrypted(header: String) -> Bool {
        if header.isEmpty {
            return false
        }
        
        if header.count < VaultFile.DEFAULT_HEADER_SIZE {
            return false
        }
        
        let identifier = UtilManager.getSubString(str: header, from: 0, to: VaultFile.IDENTIFIER_LEN)
        if identifier == VaultFile.IDENTIFIER {
            return true
        } else {
            return false
        }
    }
    
    @objc func readHeader(headerStr: [UInt8]) -> Bool {
        
        if headerStr.count < VaultFile.DEFAULT_HEADER_SIZE {
            return false
        }
        
        var pos1: Int = 0
        var pos2: Int = 0
        
        // Header XML Position
        pos1 = Int(headerStr[VaultFile.HEADER_XML_POS] & 0xff)
        pos2 = Int(headerStr[VaultFile.HEADER_XML_POS + 1] & 0xff)
        let headerXmlPosition = pos1 * 256 + pos2
        
        // Header XML Length
        pos1 = Int(headerStr[VaultFile.HEADER_XML_LEN] & 0xff)
        pos2 = Int(headerStr[VaultFile.HEADER_XML_LEN + 1] & 0xff)
        let headerXmlLength = pos1 * 256 + pos2
                
        // File content pos
        pos1 = Int(headerStr[VaultFile.FILE_CONTENT_POS] & 0xff)
        pos2 = Int(headerStr[VaultFile.FILE_CONTENT_POS + 1] & 0xff)
        let fileContentPosition = pos1 * 256 + pos2
        
        // get data buf
        let headerXmlBuf = headerStr[headerXmlPosition...headerXmlPosition + headerXmlLength - 1]
        print(headerXmlPosition)
        print(headerXmlLength)
        print(fileContentPosition)
       
        if let keyData = String(bytes: headerXmlBuf, encoding: .ascii) {
            let vaultXmlParser = VaultXmlParser()
            self.fileEncInfo = vaultXmlParser.parse(xmlBody: keyData)
            
            if(fileEncInfo == nil){
                return false;
            }else {
                return true;
            }
            
        } else {
            return false
        }
    }
    
    @objc func writeHeader() -> [UInt8]?{
        if fileEncInfo == nil {
            return nil
        }
        
        var rawHeaderBuffer: [UInt8] = [UInt8](repeating: 0, count: VaultFile.DEFAULT_HEADER_SIZE)
        
        // identifier
        var index = 0
        for ch in VaultFile.IDENTIFIER.utf8 {
            rawHeaderBuffer[index] = ch
            index += 1
        }
        
        var pos1: Int = 0
        var pos2: Int = 0
        
        // header XML pos
        pos1 = VaultFile.DEFAULT_HEADER_XML_POS / 256
        pos2 = VaultFile.DEFAULT_HEADER_XML_POS - 256 * pos1
        rawHeaderBuffer[VaultFile.HEADER_XML_POS] = UInt8(pos1)
        rawHeaderBuffer[VaultFile.HEADER_XML_POS+1] = UInt8(pos2)
        
        let vaultXmlParser = VaultXmlParser()
        let headerXml: String = vaultXmlParser.getHeaderXml(fileEncInfo: self.fileEncInfo!)
        
        // header XML length
        let headerXmlLength = headerXml.count
        pos1 = headerXmlLength / 256
        pos2 = headerXmlLength - 256 * pos1
        rawHeaderBuffer[VaultFile.HEADER_XML_LEN] = UInt8(pos1)
        rawHeaderBuffer[VaultFile.HEADER_XML_LEN+1] = UInt8(pos2)
        
        index = 0
        for ch in headerXml.utf8 {
            rawHeaderBuffer[VaultFile.DEFAULT_HEADER_XML_POS + index] = ch
            index += 1
        }
        
        // file content pos
        pos1 = VaultFile.DEFAULT_FILE_CONTENT_POS / 256
        pos2 = VaultFile.DEFAULT_FILE_CONTENT_POS - 256 * pos1
        rawHeaderBuffer[VaultFile.FILE_CONTENT_POS] = UInt8(pos1)
        rawHeaderBuffer[VaultFile.FILE_CONTENT_POS + 1] = UInt8(pos2)
        
        return rawHeaderBuffer
    }
    
    @objc func getAesKey(curAccount: Account) -> NSMutableData? {
        
        if fileEncInfo != nil && fileEncInfo?.aesKey?.length == 32 {
            return fileEncInfo?.aesKey;
        }
        
        if fileEncInfo == nil {
            return nil
        }
        
        if (fileEncInfo!.id.isEmpty || fileEncInfo!.aesEncKey?.length == 0 || fileEncInfo!.shared.isEmpty) {
            return nil
        }
        
        if fileEncInfo!.shared != "yes" && fileEncInfo!.shared != "no" {
            return nil
        }
        
        if fileEncInfo!.shared == "yes" {
            if fileEncInfo!.ownerId.isEmpty ||
                fileEncInfo!.folderPublicKey.isEmpty ||
                fileEncInfo!.folderEncPrivateKey.isEmpty ||
                fileEncInfo!.ownerEncWrappingKey.isEmpty {
                return NSMutableData()            }
        }
        
        if fileEncInfo!.shared == "no" {
            if fileEncInfo!.id != curAccount.getId() {
                 return nil;
            }

            /* Case when the current user is the owner of the none-shared file */
            var output: NSMutableData? = NSMutableData();
            var success = OpenSSL_Helper_Wrapper.base64DecodeRsaDecrypt(fileEncInfo!.aesEncKey as String?, derEncodedPrivateKey: curAccount.getDerEncodedPrivateKey(), output: &output)
            if(success == false) {
                return nil;
            }
            
            fileEncInfo!.aesKey = output
            return fileEncInfo!.aesKey;
        } else if fileEncInfo!.shared == "yes" {
            if fileEncInfo!.ownerId == curAccount.getId() {
                /* Case when the current user is the owner of the shared file */

                // Step 1: decrypt folder wrapping key using owner private key
                var folderPlainWrappingKey: NSMutableData? = NSMutableData()
                var success = OpenSSL_Helper_Wrapper.base64DecodeRsaDecrypt(fileEncInfo!.ownerEncWrappingKey, derEncodedPrivateKey: curAccount.getDerEncodedPrivateKey(), output: &folderPlainWrappingKey)
                if(success == false) {
                    return nil;
                }
                
                // Step 2: decrypt folder encrypted private key using folder wrapping key
                var folderDerEncodedPrivateKey: NSMutableData? = NSMutableData()
                success = OpenSSL_Helper_Wrapper.base64DecodeAesDecrypt(fileEncInfo!.folderEncPrivateKey, aesKey: folderPlainWrappingKey as? Data, output: &folderDerEncodedPrivateKey)
                if(success == false) {
                    return nil;
                }
                
                // Step 3: decrypt the file's encrypted aes key
                var fileAesKey: NSMutableData? = NSMutableData()
                success = OpenSSL_Helper_Wrapper.base64DecodeRsaDecrypt(fileEncInfo!.aesEncKey as? String, derEncodedPrivateKey: folderDerEncodedPrivateKey as Data?, output: &fileAesKey)
                if(success == false) {
                    return nil;
                }
                
                fileEncInfo?.aesKey = fileAesKey
                return fileAesKey
            } else {
                /* Case when the current user is not the owner of the shared file */
                
                let userId = curAccount.getId()
                let folderId = fileEncInfo?.id
                
                // Step 1: fetch the current user's wrapping key
                var currUserEncWrappingKey = WrappingKeyRequester.getWrappingKey(forUserId: userId, folderId: folderId)
                if currUserEncWrappingKey == "" {
                    return nil
                }
                
                // Step 2: decrypt folder wrapping key using current user private key
                var folderPlainWrappingKey: NSMutableData? = NSMutableData()
                var success = OpenSSL_Helper_Wrapper.base64DecodeRsaDecrypt(currUserEncWrappingKey, derEncodedPrivateKey: curAccount.getDerEncodedPrivateKey(), output: &folderPlainWrappingKey)
                if(success == false) {
                    return nil;
                }
                
                // Step 3: decrypt folder encrypted private key using folder wrapping key
                var folderDerEncodedPrivateKey: NSMutableData? = NSMutableData()
                success = OpenSSL_Helper_Wrapper.base64DecodeAesDecrypt(fileEncInfo!.folderEncPrivateKey, aesKey: folderPlainWrappingKey as? Data, output: &folderDerEncodedPrivateKey)
                if(success == false) {
                    return nil;
                }
                
                // Step 4: decrypt the file's encrypted aes key
                var fileAesKey: NSMutableData? = NSMutableData()
                success = OpenSSL_Helper_Wrapper.base64DecodeRsaDecrypt(fileEncInfo!.aesEncKey as? String, derEncodedPrivateKey: folderDerEncodedPrivateKey as? Data, output: &fileAesKey)
                if(success == false) {
                    return nil;
                }
                
                fileEncInfo?.aesKey = fileAesKey
                return fileAesKey
            }
        } else {
            // This else will never be reached but written for completeness.
            return nil;
        }
    }
    
    // SHUJAAT: Move this function out of this file.
    @objc func writeFolderKey(dirPath: String) -> Bool {
        var result = true
        
        let folderKeyPath = dirPath + "/" + VaultFile.FOLDER_KEY
        let headerBuf = writeHeader()
        
        var outputStream = OutputStream(toFileAtPath: folderKeyPath, append: false)
        if (outputStream == nil || headerBuf == nil) {
            return false
        } else {
            outputStream!.open()
            outputStream!.write(headerBuf!, maxLength: headerBuf!.count)
            outputStream!.close()
            return true
        }
    }
    
}
