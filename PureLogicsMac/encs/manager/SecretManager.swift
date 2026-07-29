//
//  SecretManager.swift
//  iosvault
//
//  Created by admin on 8/23/21.
//

import Foundation

@objc class SecretManager : NSObject {
    static let SECRET_XML_FILE = "secrets.xml"
    
    @objc nonisolated(unsafe) static var secretInfo: Secret?
    
    @objc static func getSecretInfo() -> Bool {
        do {
            let utilManager = UtilManagerC();
            var contents = utilManager!.readFile(SECRET_XML_FILE)
            if contents!.isEmpty {
                return false
            }
            
            let secretInfoXml: SecretInfoXml = SecretInfoXml()
            secretInfo = secretInfoXml.parse(xmlBody: contents!, isFile: true)
                        
            print(contents)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    @objc static func setSecretInfo() -> Bool {
        if secretInfo == nil {
            return false
        } else {
            let secretInfoXml = SecretInfoXml()
            var xmlContent = secretInfoXml.makeHeader(secret: secretInfo!, isFile: true)
            let utilManager = UtilManagerC()
            utilManager!.writeFile(SECRET_XML_FILE, andFileContent: xmlContent)
            
            return true
        }
    }
}
