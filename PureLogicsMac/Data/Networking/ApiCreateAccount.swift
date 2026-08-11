//
//  ApiCreatePassword.swift
//  PureLogicsMac
//
//  Created by Apple on 10/08/2026.
//
import Foundation

protocol ApiCreateAccountprotocol {
    func createAccount(password: NSData) throws -> [Any]
    func saveAccountToJson(userId:String, email:String, proCode:String, password:NSData) throws -> String
}

struct ApiCreateAccount: ApiCreateAccountprotocol {
    
    
    func createAccount(password: NSData) throws -> [Any] {
        let createAccount = CreateAccount()
        let results = createAccount.createUserAccount(password: password)
        guard results[5] as! Bool else {
            throw LoginError.createPasswrodFailed
        }
        return results
    }
    
    func saveAccountToJson(userId:String, email:String, proCode:String, password:NSData) throws -> String{
        do{
            let accountDetails = try createAccount(password: password)
            let myObject = postJsonForCreateAcc(
                id: userId,
                email: email,
                proCode: proCode,
                pubKey: accountDetails[0] as! String,
                privKeyIter: String(accountDetails[8] as! Int),
                privKeySalt: accountDetails[1] as! String,
                privKey: accountDetails[2] as! String,
                passIter: String(accountDetails[9] as! Int),
                passSalt: accountDetails[3] as! String,
                passHash: accountDetails[4] as! String
            )
            let jsonData = try JSONEncoder().encode(myObject)
            let postJson = String(data: jsonData, encoding: .utf8)
            _ = try JSONDecoder().decode(postJsonForCreateAcc.self, from: jsonData)
            print(postJson!)
            return postJson!
        }catch{
            throw LoginError.createPasswrodFailed
        }
    }
    // Add swiftData here to save this Data
    
    
}
