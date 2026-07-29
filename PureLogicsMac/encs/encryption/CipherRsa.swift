//
//  CipherRsa.swift
//  iosvault
//
//  Created by admin on 8/25/21.
//

import Foundation

@objc class CipherRsa : NSObject {
    static let PRIVATE_KEY_MARK = "-----BEGIN RSA PRIVATE KEY-----"
    
    static func rsaKeyGenerate(pubKey: inout String, priKey: inout String) {
        var rsaPubKey: NSData?
        var rsaPriKey: NSData?
        let result = generate_rsa_keyEx(&rsaPubKey, &rsaPriKey);
        var strPubKey = String(decoding: rsaPubKey!, as: UTF8.self)
        var strPriKey = String(decoding: rsaPriKey!, as: UTF8.self)
        
        //return (strPubKey, strPriKey)
        pubKey = strPubKey;
        priKey = strPriKey;
    }
    
    @objc static func rsaEncryptBase64(pubKey: String, plainData: String) -> String {
        var encData: NSData? = nil
        var encLen = rsa_encrypt_nsdata(pubKey.data(using: .utf8), plainData.data(using: .utf8), Int32(plainData.count), &encData)
        
        var base64Data: NSData? = nil
        if encData != nil {
            //encDataStr = encData!.base64EncodedString()
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
    
    @objc static func rsaDecryptBase64(priKey: String, encData: String) -> String {
        // decode base64
        var base64Data: NSData? = nil
        var base64Len = decode_base64_nsdata(encData.data(using: .utf8), Int32(encData.count), &base64Data)
        if base64Data == nil {
            return ""
        }
        
        var plainData: NSData? = nil
        rsa_decrypt_nsdata(priKey.data(using: .utf8), base64Data! as Data, Int32(base64Data!.count), &plainData)
        
        var strPlain = ""
        if plainData != nil {
            strPlain = String(decoding:plainData!, as: UTF8.self)
        }
        
        return strPlain
    }
    
    @objc static func isValidPrivateKey(priKey: String) -> Bool {
        let result = priKey.hasPrefix(PRIVATE_KEY_MARK)
        return result
    }
}
