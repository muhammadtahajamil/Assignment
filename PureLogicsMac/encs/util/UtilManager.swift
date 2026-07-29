//
//  UtilManager.swift
//  iosvault
//
//  Created by admin on 8/24/21.
//

import Foundation

@objc class UtilManager : NSObject{
    @objc static func getSubString(str: String, from: Int, to: Int) -> String {
        let startIndex = str.index(str.startIndex, offsetBy: from)
        let endIndex = str.index(str.startIndex, offsetBy: to)
        let range: Range = startIndex..<endIndex
        let strItem = String(str[range])
        
        return strItem
    }
    
    @objc static func readFile(fileName: String) -> String {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL)
        
        do {
            var contents = try String(contentsOf: fileURL)
            return contents
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    @objc static func writeFile(fileName: String, content: String) -> Bool {
        if (fileName.isEmpty || content.isEmpty) {
            return false
        }
        
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL)
        
        // Create data to be saved
        guard let data = content.data(using: .utf8) else {
            print("Unable to convert string to data")
            return false
        }
        
        // Save the data
        do {
         try data.write(to: fileURL)
            print("File saved: \(fileURL.absoluteURL)")
            return true
        } catch {
         // Catch any errors
         print(error.localizedDescription)
            return false
        }
    }
}
