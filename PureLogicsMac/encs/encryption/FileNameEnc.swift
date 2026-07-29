//
//  FileNameManager.swift
//  googledriveIntegration
//
//  Created by admin on 10/8/21.
//

import Foundation

@objc class FileNameEnc: NSObject {
    let ENCRYPTED_VAULT_EXT = ".mv";
    
    @objc func encrypt(name: String)-> String {
        var encName: String = ""
        
        if name.count == 0 {
            return encName
        }
        
        var tempName: String = name + ENCRYPTED_VAULT_EXT
        var srcData = tempName.data(using: .utf8)
        var dstData: NSData? = nil
        encodeBase64FileName(srcData, &dstData);
        
        if dstData != nil {
            encName = String(decoding: dstData!, as: UTF8.self)
        }
        
        return encName;
    }
    
    @objc func decrypt(name: String)-> String {
        var encName: String = ""
        
        if name.count == 0 {
            return encName
        }
        
        var srcData = name.data(using: .utf8)
        var dstData: NSData? = nil
        decodeBase64FileName(srcData, &dstData);
        
        if dstData != nil {
            encName = String(decoding: dstData!, as: UTF8.self)
            let sub = encName.prefix(encName.count - 3)
            encName = String(sub)
        }
        
        return encName;
    }
    
}
