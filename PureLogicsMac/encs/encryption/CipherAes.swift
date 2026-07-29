//
//  CipherAes.swift
//  iosvault
//
//  Created by admin on 8/25/21.
//

import Foundation

@objc class CipherAes : NSObject{
    static let AES_KEY_LEN = 32
    
    @objc static func generateRandomAesKey() -> String {
        var strKey = ""
        
        let alphaNum = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*(*)-+"
        let max = alphaNum.count
        
        for index in 0..<AES_KEY_LEN {
            let random = Int.random(in: 0..<alphaNum.count)
            let startIndex = alphaNum.index(alphaNum.startIndex, offsetBy: random)
            let endIndex = alphaNum.index(alphaNum.startIndex, offsetBy: random+1)
            let range: Range = startIndex..<endIndex
            let strItem = String(alphaNum[range])
            strKey += strItem
        }
        
        return strKey
    }
    
    @objc static func aesEncryptBase64(key: String, plainData: String) -> String {
        
        var encData: NSData? = nil
        var encLen = aes_encrypt_sharp(key.data(using: .utf8), nil, plainData.data(using: .utf8), &encData)
        
        var base64Data: NSData? = nil
        if encData != nil {
            encode_base64_nsdata(encData! as Data, encLen, &base64Data)
        }
        
        var strBase64 = ""
        if base64Data != nil {
            var str = String(data: base64Data! as Data, encoding: .utf8)
            if str != nil {
                strBase64 = str!
            }
        }
        
        return strBase64
    }
    
    @objc static func aesDecryptBase64(key: String, encData: String) -> String {
        // decode base64
        var base64Data: NSData? = nil
        var base64Len = decode_base64_nsdata(encData.data(using: .utf8), Int32(encData.count), &base64Data)
        if base64Data == nil {
            return ""
        }
        
        var plainData: NSData? = nil
        aes_decrypt_sharp(key.data(using: .utf8), Int32(key.count), nil, base64Data! as Data, Int32(base64Len), &plainData)
        
        var strPlain = ""
        if plainData != nil {
            strPlain = String(decoding:plainData!, as: UTF8.self)
        }
        
        return strPlain
    }
    
    
    @objc func aesEncryptBase64New(key: String, plainData: String) -> String {
        
        var encData: NSData? = nil
        var encLen = aes_encrypt_sharp(key.data(using: .utf8), nil, plainData.data(using: .utf8), &encData)
        
        var base64Data: NSData? = nil
        if encData != nil {
            encode_base64_nsdata(encData! as Data, encLen, &base64Data)
        }
        
        var strBase64 = ""
        if base64Data != nil {
            var str = String(data: base64Data! as Data, encoding: .utf8)
            if str != nil {
                strBase64 = str!
            }
        }
        
        print("encoded data: \(strBase64)")
       // return strBase64
        
        let str = "X8j6GO3Ionxai/MTVCkFFg=="
        
        // decode base64
        var base64Data2: NSData? = nil
        var base64Len = decode_base64_nsdata(str.data(using: .utf8), Int32(str.count), &base64Data)
        if base64Data2 == nil {
            return ""
        }
        
        var plainData: NSData? = nil
        aes_decrypt_sharp(key.data(using: .utf8), Int32(key.count), nil, base64Data2! as Data, Int32(base64Len), &plainData)
        
        var strPlain = ""
        if plainData != nil {
            strPlain = String(decoding:plainData!, as: UTF8.self)
        }
        
        print("decoded data: \(strPlain)")
        
        return ""
    }
    
    
    @objc func aesDecryptBase64New(key: String, encData: String) -> String {
        // decode base64
        var base64Data: NSData? = nil
        var base64Len = decode_base64_nsdata(encData.data(using: .utf8), Int32(encData.count), &base64Data)
        if base64Data == nil {
            return ""
        }
        
        var plainData: NSData? = nil
        aes_decrypt_sharp(key.data(using: .utf8), Int32(key.count), nil, base64Data! as Data, Int32(base64Len), &plainData)
        
        var strPlain = ""
        if plainData != nil {
            strPlain = String(decoding:plainData!, as: UTF8.self)
        }
        
        return strPlain
    }
    
    
    @objc static func aesEncrypt(key: String, plainData: [UInt8]) -> [UInt8] {
        
        var encData: NSData? = nil
        var encLen = aes_encrypt_sharp(Data(plainData), nil, key.data(using: .utf8), &encData)
        
        if encData != nil {
            return Array(encData!)
        } else {
            return []
        }
    }
    
    @objc static func aesDecrypt(key: String, encData: [UInt8]) -> [UInt8] {
                
        var plainData: NSData? = nil
        aes_decrypt_sharp(key.data(using: .utf8), Int32(key.count), nil, Data(encData), Int32(encData.count), &plainData)
        
        if plainData != nil {
            return Array(plainData!)
        } else {
            return []
        }
    }
        
}
