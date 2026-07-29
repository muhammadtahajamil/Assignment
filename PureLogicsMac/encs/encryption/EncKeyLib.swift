import Foundation

@objc class EncKeyLib : NSObject {
    let AES_KEY_LEN = 32
    
    func test() {
        if AccountManager.getCurrentAccount() != nil {
            let fileName = "test.txt"
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL)
            
            let fileName1 = "test1.txt"
            let fileURL1 = URL(fileURLWithPath: fileName1, relativeTo: directoryURL)
            
            var vaultFile = VaultFile(account: AccountManager.getCurrentAccount()!, fileName: fileName)
            
            let utilManager = UtilManagerC()
            let content = utilManager!.readFile("accounts.xml")
            let aesKey = vaultFile.fileEncInfo?.aesKey
            if (aesKey != nil && aesKey?.isEmpty == false){
                var outstream = OutputStream(url: fileURL1, append: false)
                if let stream = InputStream(url: fileURL) {
                    var buf = [UInt8](repeating: 0, count: 1024)
                    stream.open()

                    while case let amount = stream.read(&buf, maxLength: 1024), amount > 0 {
                        print(amount)
                        //chunks.append(Array(buf[..<amount]))
                        outstream?.write(buf, maxLength: 1024)
                    }
                    stream.close()
                    outstream?.close()
                }
            }
        }
    }
    
    @objc func generateRandomAesKey() -> String {
        var strKey: String = "";
        let alphaNum = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*(*)-+";
        
        let max = alphaNum.count
        strKey = String((0..<AES_KEY_LEN).map{_ in alphaNum.randomElement()!})
        
        return strKey;
    }
    
    

    @objc func encryptFileConcurrently(srcFile: URL, dstFile: URL, vaultFile: VaultFile) -> Bool {
        // Validate AES Key
        guard let aesKey = vaultFile.getAesKey(curAccount: AccountManager.getCurrentAccount()!),
              !aesKey.isEmpty, aesKey.length == AES_KEY_LEN else {
            return false
        }
        
        // Open input and output streams
        guard let inputStream = InputStream(url: srcFile),
              let outputStream = OutputStream(url: dstFile, append: false) else {
            print("Failed to create input/output streams")
            return false
        }
        
        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }
        
        // Write file header
        if let header = vaultFile.writeHeader() {
            if outputStream.write(header, maxLength: header.count) == -1 {
                print("Error writing header")
                return false
            }
        }
        
        // Parameters
        let bufferSize = 8192 // 64 KB chunks
        let queue = DispatchQueue(label: "encryption.queue", attributes: .concurrent) // Concurrent queue for parallel encryption
        let group = DispatchGroup() // Group to manage concurrent tasks
        var encryptedChunks: [(blockNum: Int64, encryptedData: Data)] = []
        var blockNum: Int64 = 0
        var encryptionError = false
        let syncQueue = DispatchQueue(label: "sync.queue") // Serial queue to synchronize chunk appending
        
        // Read and encrypt in chunks
        while true {
            var readBuf = [UInt8](repeating: 0, count: bufferSize)
            let bytesRead = inputStream.read(&readBuf, maxLength: bufferSize)
            
            if bytesRead < 0 {
                print("Error reading input stream")
                return false
            } else if bytesRead == 0 {
                break // End of file
            }
            
            let readBufData = Data(bytes: readBuf, count: bytesRead)
            group.enter() // Track the encryption task in the group

            // Create a DispatchWorkItem
            let workItem = DispatchWorkItem {
                // Encrypt the chunk
                var encBuf: NSData? = nil
                let encLength = contentEncrypt(aesKey as Data, Int32(aesKey.length), readBufData as NSData as Data, Int32(bytesRead), &encBuf, blockNum)
                
                if encLength > 0, let encryptedData = encBuf {
                    let chunkData = Data(bytes: encryptedData.bytes, count: Int(encLength))
                    
                    // Append encrypted chunk in a thread-safe manner
                    syncQueue.sync {
                        encryptedChunks.append((blockNum, chunkData))
                    }
                } else {
                    encryptionError = true
                }
                group.leave() // Mark the encryption task as complete
            }

            // Submit the work item to the concurrent queue
            queue.async(execute: workItem)
            
            blockNum += 1
        }
        
        // Wait for all encryption tasks to complete
        group.wait()
        
        if encryptionError {
            print("Error occurred during encryption")
            return false
        }
        
        // Sort chunks by block number and write to output stream
        encryptedChunks.sort { $0.blockNum < $1.blockNum }
        for chunk in encryptedChunks {
            let bytesWritten = chunk.encryptedData.withUnsafeBytes { buffer in
                outputStream.write(buffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: chunk.encryptedData.count)
            }
            
            if bytesWritten == -1 {
                print("Error writing to output stream")
                return false
            }
        }
        
        print("File encryption completed successfully")
        return true
    }

    
    
    //
    @objc func encryptFileFaizan(srcFile: String, dstFile: String, vaultFile: VaultFile) -> Bool {
            
            if vaultFile.fileEncInfo == nil {
                return false;
            }
            
            guard let aesKey = vaultFile.getAesKey(curAccount: AccountManager.getCurrentAccount()!),
                  !aesKey.isEmpty, aesKey.length == AES_KEY_LEN else {
                return false
            }
            
            // get stream
            guard let inputStream = InputStream(fileAtPath: srcFile),
                  let outputStream = OutputStream(toFileAtPath: dstFile, append: false) else {
                return false
            }
            print("==== enter encryptFile ====")
//            HelperClass.dePrint("==== enter encryptFile ====")
            // header
            inputStream.open()
            outputStream.open()
            
            defer {
                inputStream.close()
                outputStream.close()
            }
            
            // Write header
            if let header = vaultFile.writeHeader() {
                _ = outputStream.write(header, maxLength: header.count)
            }
                
            // write file content
            var readBuf = [UInt8](repeating: 0, count: 8192)
            var blockNum: Int64 = 0
                    
            var encBuf: NSData? = nil
        print("==== mid encryptFile ====")
//            HelperClass.dePrint("==== mid encryptFile ====")
            while case let amount = inputStream.read(&readBuf, maxLength: 8192), amount > 0 {
                autoreleasepool {
                    // Explicitly release the encData object to free memory
                    encBuf = nil
                    
                    let encLength = contentEncrypt(aesKey as Data, Int32(aesKey.length), Data(bytes: readBuf, count: amount), Int32(amount), &encBuf, blockNum)
                    
                    if(encLength <= 0 || encBuf == nil) {
                        return // End of the input stream or error
                    }
                    
                    // Write the encrypted data to the output stream
                    if let encBuff = encBuf {
                        let outBuf = [UInt8](encBuff)
                        _ = outputStream.write(outBuf, maxLength: Int(encLength))
                    }
                    
                    // Explicitly release the encData object to free memory
                    encBuf = nil
                    
                    blockNum += 1
                    print("==== encryptFile loop \(blockNum) ====")
//                    HelperClass.dePrint("==== encryptFile loop \(blockNum) ====")
                }
            }
        print("==== exit encryptFile ====")
//            HelperClass.dePrint("==== exit encryptFile ====")
            return true;
        }
    
    //
    
    @objc func encryptFile(account: Account, srcFile: String, dstFile: String, vaultFile: VaultFile) -> Bool {
        
        if vaultFile.fileEncInfo == nil {
            return false
        }
        
        guard let aesKey = vaultFile.getAesKey(curAccount: account),
              !aesKey.isEmpty,
              aesKey.length == AES_KEY_LEN else {
            return false
        }

        guard let inputStream = InputStream(fileAtPath: srcFile),
              let outputStream = OutputStream(toFileAtPath: dstFile, append: false) else {
            return false
        }

        inputStream.open()
        outputStream.open()

        if let header = vaultFile.writeHeader() {
            outputStream.write(header, maxLength: header.count)
        }

        let readBufSize = 8192
        let encryptionQueue = DispatchQueue(label: "encryption.queue", attributes: .concurrent)
        let writeQueue = DispatchQueue(label: "write.queue") // Serial queue for ordered writing
        let group = DispatchGroup()

        var blockNum: Int64 = 0
        nonisolated(unsafe) var shouldStop = false
        let startDate = Date()

        let lock = NSLock()
        nonisolated(unsafe) var encryptedChunks: [Int64: Data] = [:]
        var nextBlockToWrite: Int64 = 0

        while !shouldStop {
            nonisolated(unsafe) var readBuf = [UInt8](repeating: 0, count: readBufSize)
            let amount = inputStream.read(&readBuf, maxLength: readBufSize)

            if amount <= 0 {
                break
            }

            let currentBlock = blockNum
            blockNum += 1

            group.enter()
            encryptionQueue.async {
                autoreleasepool {
                    let readBufData = NSData(bytes: readBuf, length: amount)
                    var encBuf: NSData? = nil

                    let encLength = contentEncrypt(aesKey as Data, Int32(aesKey.length), readBufData as Data, Int32(amount), &encBuf, currentBlock)

                    if encLength > 0, let encryptedData = encBuf {
                        lock.lock()
                        encryptedChunks[currentBlock] = encryptedData as Data
                        lock.unlock()
                    } else {
                        shouldStop = true
                    }

                    // Explicitly release memory
                    encBuf = nil
                    group.leave()
                }
            }
        }

        // Ensure encryption is done before writing
        group.notify(queue: writeQueue) {
            while nextBlockToWrite < blockNum {
                lock.lock()
                if let data = encryptedChunks.removeValue(forKey: nextBlockToWrite) { // Free memory immediately
                    let outBuf = [UInt8](data)
                    outputStream.write(outBuf, maxLength: data.count)
                    nextBlockToWrite += 1
                }
                lock.unlock()
            }

            inputStream.close()
            outputStream.close()
            
            let endDate = Date()
            let timeInterval = endDate.timeIntervalSince(startDate)
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            let milliseconds = Int((timeInterval - floor(timeInterval)) * 1000)

            print("Time taken: \(minutes) min \(seconds) sec \(milliseconds) ms")
        }

        return true
    }

    
//    @objc func encryptFile(srcFile: String, dstFile: String, vaultFile: VaultFile) -> Bool {
//        
//        if vaultFile.fileEncInfo == nil {
//            return false;
//        }
//        
//        let aesKey : NSMutableData? = vaultFile.getAesKey(curAccount: AccountManager.getCurrentAccount()!)
//        if aesKey == nil || aesKey!.isEmpty || aesKey!.length != AES_KEY_LEN {
//            return false;
//        }
//        
//        // get stream
//        let inputStream = InputStream(fileAtPath: srcFile);
//        let outputStream = OutputStream(toFileAtPath: dstFile, append: false)
//        
//        // check param
//        if inputStream == nil || outputStream == nil {
//            return false
//        }
//        
//        // header
//        inputStream!.open()
//        outputStream!.open()
//        
//        let header = vaultFile.writeHeader()
//        outputStream!.write(header!, maxLength: header!.count)
//        
//        // write file content
//        var readBuf = [UInt8](repeating: 0, count: 8192)
//        var blockNum: Int64 = 0
//                
//        while case let amount = inputStream!.read(&readBuf, maxLength: 8192), amount > 0 {
//            let readBufData = NSData(bytes: readBuf, length: amount)
//            
//            var encBuf: NSData? = nil
//            let encLength = contentEncrypt(aesKey as Data?, Int32(aesKey!.length), readBufData as Data, Int32(amount), &encBuf, blockNum)
//            
//            if(encLength <= 0 || encBuf == nil) {
//                break;
//            }
//            
//            let outBuf = [UInt8](encBuf!)
//            outputStream!.write(outBuf, maxLength: Int(encLength))
//            
//            blockNum += 1
//        }
//        
//        inputStream!.close()
//        outputStream!.close()
//                
//        return true;
//    }
    
    func encryptFile(content: inout Data, dstFilePath: String, vaultFile: VaultFile) -> Bool {
        
        if vaultFile.fileEncInfo == nil {
            return false;
        }
        
        let aesKey : NSMutableData? = vaultFile.getAesKey(curAccount: AccountManager.getCurrentAccount()!)
        if aesKey == nil || aesKey!.isEmpty || aesKey!.length != AES_KEY_LEN {
            return false;
        }
        
        // get stream
        let outputStream = OutputStream(toFileAtPath: dstFilePath, append: false)
        
        // check param
        if outputStream == nil {
            return false
        }
        
        // header
        outputStream!.open()
        
        let header = vaultFile.writeHeader()
        outputStream!.write(header!, maxLength: header!.count)
        
        // write file content
        var blockNum: Int64 = 0
        let totalLength = content.count
        var offset = 0
                
        if totalLength > 0 {
            while offset < totalLength {
                let amount = min(8192, totalLength - offset)
                let readBufData = content.subdata(in: offset..<offset + amount)
                
                var encBuf: NSData? = nil
                let encLength = contentEncrypt(aesKey as Data?, Int32(aesKey!.length), readBufData as Data, Int32(amount), &encBuf, blockNum)
                
                if(encLength <= 0 || encBuf == nil) {
                    break
                }
                
                let outBuf = [UInt8](encBuf!)
                outputStream!.write(outBuf, maxLength: Int(encLength))
                
                offset += amount
                blockNum += 1
            }
        }
        
        outputStream!.close()
                
        return true;
    }
    
    @objc func decryptFile(srcFile: String, dstFile: String, vaultFile: VaultFile) -> Bool {
        // Get input and output streams
        guard let inputStream = InputStream(fileAtPath: srcFile),
              let outputStream = OutputStream(toFileAtPath: dstFile, append: false) else {
            return false
        }

        inputStream.open()

        // Read header
        var headerBuf = [UInt8](repeating: 0, count: VaultFile.DEFAULT_HEADER_SIZE)
        let readHeaderCnt = inputStream.read(&headerBuf, maxLength: VaultFile.DEFAULT_HEADER_SIZE)
        if readHeaderCnt < VaultFile.DEFAULT_HEADER_SIZE {
            inputStream.close()
            return false
        }

        guard let strHeader = String(bytes: headerBuf, encoding: .ascii),
              vaultFile.isEncrypted(header: strHeader),
              vaultFile.readHeader(headerStr: headerBuf) else {
            inputStream.close()
            return false
        }

        guard let account = AccountManager.getCurrentAccount(),
              let aesKey = vaultFile.getAesKey(curAccount: account),
              !aesKey.isEmpty, aesKey.length == AES_KEY_LEN else {
            inputStream.close()
            return false
        }

        // Open output stream
        outputStream.open()

        // Parallel Decryption Setup
        let readBufSize = 8192
        let decryptionQueue = DispatchQueue(label: "decryption.queue", attributes: .concurrent)
        let writeQueue = DispatchQueue(label: "write.queue") // Serial queue for ordered writes
        let group = DispatchGroup()

        var blockNum: Int64 = 0
        let lock = NSLock()
        nonisolated(unsafe) var decryptedChunks: [Int64: Data] = [:]
        var nextBlockToWrite: Int64 = 0
        nonisolated(unsafe) var shouldStop = false

        let startDate = Date()

        while !shouldStop {
            nonisolated(unsafe) var readBuf = [UInt8](repeating: 0, count: readBufSize)
            let amount = inputStream.read(&readBuf, maxLength: readBufSize)
            
            if amount <= 0 {
                break
            }
            
            let currentBlock = blockNum
            blockNum += 1
            
            group.enter()
            decryptionQueue.async {
                autoreleasepool {
                    let readBufData = NSData(bytes: readBuf, length: amount)
                    
                    var decData: NSData? = nil
                    let decLength = contentDecrypt(aesKey as Data?, Int32(aesKey.length), readBufData as Data, Int32(amount), &decData, currentBlock)
                    
                    if decLength > 0, let decryptedData = decData {
                        lock.lock()
                        decryptedChunks[currentBlock] = decryptedData as Data
                        lock.unlock()
                    } else {
                        shouldStop = true
                    }
                    
                    group.leave()
                }
            }
        }

        // Ensure decryption is done before writing
        group.notify(queue: writeQueue) {
            while nextBlockToWrite < blockNum {
                lock.lock()
                if let data = decryptedChunks[nextBlockToWrite] {
                    let outBuf = [UInt8](data)
                    outputStream.write(outBuf, maxLength: data.count)
                    decryptedChunks.removeValue(forKey: nextBlockToWrite) // Free memory
                    nextBlockToWrite += 1
                }
                lock.unlock()
            }

            inputStream.close()
            outputStream.close()

            let endDate = Date()
            let timeInterval = endDate.timeIntervalSince(startDate)
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            let milliseconds = Int((timeInterval - floor(timeInterval)) * 1000)

            print("Decryption Time: \(minutes) min \(seconds) sec \(milliseconds) ms")
        }

        return true
    }

    
    func decryptFile(srcFile: String, decryptedContent: inout String, vaultFile: VaultFile) -> Bool {
        
        // get stream
        let inputStream = InputStream(fileAtPath: srcFile);
        
        // check param
        if (inputStream == nil) {
            return false
        }
        
        inputStream!.open()
        
        // read header
        var headerBuf = [UInt8](repeating: 0, count: VaultFile.DEFAULT_HEADER_SIZE)
        let readHeaderCnt = inputStream!.read(&headerBuf, maxLength: VaultFile.DEFAULT_HEADER_SIZE)
        if readHeaderCnt < VaultFile.DEFAULT_HEADER_SIZE {
            inputStream!.close()
            return false
        }
                
        let strHeader = String(bytes: headerBuf, encoding: .ascii)
        if strHeader == nil {
            inputStream!.close()
            return false
        }
        
        // check is file is encryted
        let isEncrypted = vaultFile.isEncrypted(header: strHeader!)
        if !isEncrypted {
            inputStream!.close()
            return false
        }
        
        // get key
        let isRead = vaultFile.readHeader(headerStr: headerBuf)
        if !isRead {
            inputStream!.close()
            return false
        }
        
        if(AccountManager.getCurrentAccount() == nil) {
            return false;
        }
        
        let aesKey = vaultFile.getAesKey(curAccount: AccountManager.getCurrentAccount()!)
         
        if (aesKey == nil || aesKey!.isEmpty || aesKey!.length != AES_KEY_LEN) {
            inputStream!.close()
            return false;
        } else {
            // TODO: Look into the following commented code and fix it if required.
            //VaultManager.updateVaultFile(vaultFile: vaultFile)
        }
        
        // write file content
        var readBuf = [UInt8](repeating: 0, count: 8192)
        var blockNum: Int64 = 0
        
        var decryptedData = NSMutableData() // Initialize an empty Data object
        
        while case let amount = inputStream!.read(&readBuf, maxLength: 8192), amount > 0 {
            let readBufData = NSData(bytes: readBuf, length: amount)
            
            var decData: NSData? = nil
            let decLength = contentDecrypt(aesKey as Data?, Int32(aesKey!.length), readBufData as Data, Int32(amount), &decData, blockNum)
            
            if(decLength <= 0 || decData == nil) {
                break;
            }
            
            let data = decData! as Data
            
            if let string = String(data: data, encoding: .utf8) {
                decryptedContent.append(string);
            } else {
                return false;
            }
            
            blockNum += 1
        }
        
        inputStream!.close()
                
        return true;
    }
}
