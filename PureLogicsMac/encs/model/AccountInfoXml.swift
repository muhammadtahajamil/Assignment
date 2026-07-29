//
//  AccountInfoXml.swift
//  iosvault
//
//  Created by admin on 8/15/21.
//

import Foundation

class AccountInfoXml: NSObject, XMLParserDelegate {
    let NODE_USERS = "accounts"
    let NODE_USER = "account"
    let NODE_ID: String = "id"
    let NODE_EMAIL: String = "email"
    let NODE_RSA_PUBLIC_KEY : String = "rsa_public_key"
    let NODE_RSA_PRIVATE_KEY : String = "rsa_private_key"
    let NODE_PRIVATE_KEY_ITER : String = "private_key_iter"
    let NODE_PRIVATE_KEY_SALT : String = "private_key_salt"
    let NODE_PASSWORD_ITER : String = "password_iter"
    let NODE_MISCELLANEOUS : String = "miscellaneous"
    
    let XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" +
        "<!DOCTYPE accounts><accounts version=\"1\">"
    
    let XML_FOOTER = "</accounts>"

    //The following four variables are used to store the state of the xml parsing used in delegates below.
    var currentElement: String = ""
    var passData: Bool = false
    var curAccount: Account?
    var arrAccounts = [Account]()
    
    override init() {
        
    }

    //parser methods
    func parse(xmlBody: String, isFile: Bool) -> [Account] {
        // Reset state variables:
        currentElement = "";
        passData = false;
        curAccount = nil;
        arrAccounts.removeAll()
        
        var xmlBodyStr = xmlBody
        
        if !isFile {
            xmlBodyStr = XML_HEADER + xmlBody + XML_FOOTER
        }
        
        let xmlData = Data(xmlBodyStr.utf8)
        
        let xmlParser = XMLParser(data: xmlData)
        xmlParser.delegate = self
        
        let success = xmlParser.parse()
        if !success {
            return [Account]()
        }
        
        return arrAccounts
    }

    //MARK: XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        
        // start element
        if elementName == NODE_USER {
            curAccount = Account()
        }
        passData = true
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
        
        if elementName == NODE_USER {
            if (curAccount == nil ||
                curAccount?.getId().isEmpty == true ||
                curAccount?.getEmail().isEmpty == true ||
                curAccount?.getBase64DerEncodedPublicKey().isEmpty == true ||
                curAccount?.getBase64EncodedSecurePrivateKey().isEmpty == true ||
                curAccount?.getPrivateKeyIterations() == 0 ||
                curAccount?.getBase64EncodedPrivateKeySalt().isEmpty == true ||
                curAccount?.getPasswordIterations() == 0 ||
                curAccount?.getAesEncryptedBase64EncodedAccountDetails().isEmpty == true) {
                // We do not add account if any of the account details is missing.
            }
            else {
                arrAccounts.append(curAccount!)
            }
        }
        
        passData = false
    }

    func parser(_ parser: XMLParser, foundCharacters content: String) {
        if passData
        {
            switch currentElement {
                
            case NODE_ID:
                if content.isEmpty == false {
                    curAccount?.setId(content)
                }
                
            case NODE_EMAIL:
                if content.isEmpty == false {
                    curAccount?.setEmail(content)
                }
                
            case NODE_RSA_PUBLIC_KEY:
                if content.isEmpty == false {
                    curAccount?.setBase64DerEncodedPublicKey(content)
                }
                
                
            case NODE_RSA_PRIVATE_KEY:
                if content.isEmpty == false {
                    curAccount?.setBase64EncodedSecurePrivateKey(content)
                }
                
            case NODE_PRIVATE_KEY_ITER:
                if let intValue = Int(content) {
                    curAccount?.setPrivateKeyIterations(intValue)
                } else {
                    curAccount?.setPrivateKeyIterations(0)
                }
                
            case NODE_PRIVATE_KEY_SALT:
                if content.isEmpty == false {
                    curAccount?.setBase64EncodedPrivateKeySalt(content)
                }
                
            case NODE_PASSWORD_ITER:
                if let intValue = Int(content) {
                    curAccount?.setPasswordIterations(intValue)
                } else {
                    curAccount?.setPasswordIterations(0)
                }
                
            case NODE_MISCELLANEOUS:
                if content.isEmpty == false {
                    curAccount?.setAesEncryptedBase64EncodedAccountDetails(content)
                }
                            
            default:
                break
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        arrAccounts.removeAll()
    }
    
    func makeHeader(accountsList: [Account], isFile: Bool) -> String {
        if accountsList.isEmpty == true {
            return ""
        }
        
        var accounts: String = ""
       
        for account in accountsList {
            let id = String(format: "<%@>%@</%@>", NODE_ID, account.getId(), NODE_ID)
            let email = String(format: "<%@>%@</%@>", NODE_EMAIL, account.getEmail(), NODE_EMAIL)
            let base64DerEncodedPublicKey = String(format: "<%@>%@</%@>", NODE_RSA_PUBLIC_KEY, account.getBase64DerEncodedPublicKey(), NODE_RSA_PUBLIC_KEY)
            let base64EncodedSecurePrivateKey = String(format: "<%@>%@</%@>", NODE_RSA_PRIVATE_KEY, account.getBase64EncodedSecurePrivateKey(), NODE_RSA_PRIVATE_KEY)
            let privateKeyIterations = String(format: "<%@>%@</%@>", NODE_PRIVATE_KEY_ITER, String(account.getPrivateKeyIterations()), NODE_PRIVATE_KEY_ITER)
            let base64EncodedPrivateKeySalt = String(format: "<%@>%@</%@>", NODE_PRIVATE_KEY_SALT, account.getBase64EncodedPrivateKeySalt(), NODE_PRIVATE_KEY_SALT)
            let passwordIterations = String(format: "<%@>%@</%@>", NODE_PASSWORD_ITER, String(account.getPasswordIterations()), NODE_PASSWORD_ITER)
            let aesEncryptedBase64EncodedAccountDetails = String(format: "<%@>%@</%@>", NODE_MISCELLANEOUS, account.getAesEncryptedBase64EncodedAccountDetails(), NODE_MISCELLANEOUS)
            let userAccount = String(format: "<%@>%@%@%@%@%@%@%@%@</%@>", NODE_USER, id, email, privateKeyIterations, passwordIterations, aesEncryptedBase64EncodedAccountDetails, base64DerEncodedPublicKey, base64EncodedSecurePrivateKey, base64EncodedPrivateKeySalt, NODE_USER)
            
            accounts += userAccount
        }
        
        if isFile {
            accounts = String(format: "%@%@%@", XML_HEADER, accounts, XML_FOOTER)
        }
        
        return accounts
    } 
    
}
