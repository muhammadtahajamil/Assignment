import Foundation

@objc class AccountManager : NSObject {
    
    static let ACCOUNT_XML_FILE = "fl10_accounts.xml"
    
    private nonisolated(unsafe) static var curAccount: Account?
    private nonisolated(unsafe) static var arrAccounts = [Account]()
    
    
    @objc static func getCurrentAccount() -> Account? {
        return curAccount
    }
    
    // Check for the duplicate accounts
    @objc static func hasDuplicateAccounts(accountsList:[Account]) -> Bool {
        var emailSet = Set<String>()
        
        for account in accountsList {
            if emailSet.contains(account.getEmail()) {
                // Duplicate found
                return true
            } else {
                emailSet.insert(account.getEmail())
            }
        }
        // No duplicates
        return false
    }
    
    // TODO: Future Work, return a structure containing accounts and a boolean to show if fl10_accounts.xml is either corrupted or not.
    // If fl10_accounts.xml is corrupted then possible message could be like this: Local details are outdated, to login, internet is required.
    @objc static func loadAccountsFromLocalXmlFile() {
        curAccount = nil
        arrAccounts.removeAll()
        
        let contents = UtilManager.readFile(fileName: ACCOUNT_XML_FILE)
        
        if contents != "" {
            print("fl10_accounts.xml: \(contents)")
            
            let accountInfoXml: AccountInfoXml = AccountInfoXml()
            let accountsList = accountInfoXml.parse(xmlBody: contents, isFile: true)
            print(contents)
            
            if(hasDuplicateAccounts(accountsList:accountsList)) {
                arrAccounts = [Account]();
            } else {
                arrAccounts = accountsList;
            }
        } else {
            //print("Failed to read contents of the file")
        }
    }
    
    @objc static func SaveAccountInLocalXmlFileAndMakeItCurrent(account:Account) -> Bool {
        var aesEncryptedBase64EncodedAccountDetails: NSString?
        
        var success = SecureAccount_Wrapper.encryptUserAccountDetails(
            account.getEmail(),
            passwordSha256Hash: account.getPasswordHash(),
            derEncodedPrivateKeySha256Hash: account.getPrivateKeyHash(),
            subscription: account.getSubscription(),
            defaultCloud: account.getDefaultCloud(),
            userStatus: account.getStatus(),
            numberOfDevices: String(account.getNumberOfDevices()),
            cardExpiry: account.getCardExpiry(),
            cardLastFourDigits: account.getCardLastFourDigits(),
            subscriptionDate: account.getSubscriptionDate(),
            subscriptionExpiryDate: account.getSubscriptionExpiryDate(),
            activationCode: account.getActivationCode(),
            aesEncryptedBase64EncodedAccountDetails: &aesEncryptedBase64EncodedAccountDetails)
        
        if (aesEncryptedBase64EncodedAccountDetails != nil) {
            account.setAesEncryptedBase64EncodedAccountDetails(aesEncryptedBase64EncodedAccountDetails! as String)
            
            AccountManager.loadAccountsFromLocalXmlFile()
            AccountManager.removeAccountByEmail(account.getEmail())
            AccountManager.addAccount(account)
            AccountManager.setCurrentAccount(account: account)
            
            let accountInfoXml = AccountInfoXml()
            let xmlContent = accountInfoXml.makeHeader(accountsList: arrAccounts, isFile: true)
            
            if(UtilManager.writeFile(fileName: ACCOUNT_XML_FILE, content: xmlContent)) {
                // Successfully saved accounts including the current account in fl10_accounts.xml!
                return true;
            } else {
                // Failed to save accounts including the current account in fl10_accounts.xml!
                return false;
            }
            
        } else {
            // Failed to encrypt user account details
            return false;
        }
    }
    
    // This function removes account from the arrAccounts only! it's not intended to remove account from
    // either database or local accounts xml file.
    @objc static func removeAccountByEmail(_ email: String) {
        guard !email.isEmpty && !arrAccounts.isEmpty else {
            return
        }

        // Remove all accounts with the specified email by iterating through the array
        arrAccounts.removeAll { $0.getEmail() == email }
    }
    
    
    @objc static func addAccount(_ account: Account) {
        // Ensure the account is not added twice by first removing any existing account with the same email
        removeAccountByEmail(account.getEmail())
        
        // Add the account to the array
        arrAccounts.append(account)
    }
    
    // Beware: Call this only from Reset Account!
    @objc static func removeAccountFromLocalXmlFile(accountEmail: String) -> Bool {
        AccountManager.loadAccountsFromLocalXmlFile()
        
        if AccountManager.getAccountByEmail(email: accountEmail) != nil {
            
            AccountManager.removeAccountByEmail(accountEmail)
            
            let accountInfoXml = AccountInfoXml()
            let xmlContent = accountInfoXml.makeHeader(accountsList: arrAccounts, isFile: true)
            
            if UtilManager.writeFile(fileName: ACCOUNT_XML_FILE, content: xmlContent) {
                // Successfully removed account from fl10_accounts.xml file.
                return true
            } else {
                // Failed to remove account from fl10_accounts.xml file.
                return false
            }
        } else {
            return true
        }
    }
    
    @objc static func getAccountById(id: String) -> Account? {
        if id.isEmpty {
            return nil
        }
        
        for account in arrAccounts {
            if id == account.getId() {
                return account
            }
        }
        
        return nil
    }
       
    // This function returns account from the arrAccounts only! it's not intended to return account from
    // either database or local accounts xml file.
    @objc static func getAccountByEmail(email: String) -> Account? {
        if email.isEmpty || arrAccounts.isEmpty {
            return nil
        }

        for account in arrAccounts {
            if email == account.getEmail() {
                // We expect that arrAccounts has only one copy of an account!
                return account
            }
        }

        return nil
    }
    
    @discardableResult
    @objc static func setCurrentAccount(account: Account) -> Bool {
        if account.getId().isEmpty {
            return false
        }
        
        for accountItem in arrAccounts {
            if account.getId() == accountItem.getId() {
                curAccount = accountItem
                return true
            }
        }
        
        return false
    }
    
    //===========================================================
    
    @objc static func resetAccount(email: String){
        let accountInfoXml = AccountInfoXml()
        for account in arrAccounts {
            if account.getEmail() == email {
                arrAccounts.removeAll { $0.getEmail() == email }
            }
        }
        
        let xmlContent = accountInfoXml.makeHeader(accountsList: arrAccounts, isFile: true)
        
        let utilManager = UtilManagerC()
        _ = utilManager!.writeFile(ACCOUNT_XML_FILE, andFileContent: xmlContent)
    }
    
    @objc static func test() {
        
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: ACCOUNT_XML_FILE, relativeTo: directoryURL)
        
        // Create data to be saved
        let myString = "Saving data with FileManager is easy!"
        guard let data = myString.data(using: .utf8) else {
            print("Unable to convert string to data")
            return
        }
        // Save the data
        do {
         try data.write(to: fileURL)
            print("File saved: \(fileURL.absoluteURL)")
        } catch {
         // Catch any errors
         print(error.localizedDescription)
        }
    }
    
    @objc static func getAccounts() {
        //let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let fileURL = URL(fileURLWithPath: ACCOUNT_XML_FILE, relativeTo: directoryURL)
        
        do {
            //var contents = try String(contentsOf: fileURL)
            let utilManager = UtilManagerC()
            let contents = utilManager!.readFile(ACCOUNT_XML_FILE)
            print("fl10_accounts.xml: \(contents!)")
            
            let accountInfoXml: AccountInfoXml = AccountInfoXml()
            arrAccounts = accountInfoXml.parse(xmlBody: contents!, isFile: true)
                        
            print(contents!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @objc static func createNewPriKey(password: String) -> Bool {
        if(password.isEmpty){
            return false
        }
        var _:Account = Account()
        
        arrAccounts.removeAll()
        
//        let isCreated = account.createPriKeyOnly(password: password)
//        if isCreated {
//            arrAccounts.append(account)
//            let accountInfoXml = AccountInfoXml()
//            let xmlContent = accountInfoXml.makeHeader(arrItemList: arrAccounts, isFile: true)
//            
//            let utilManager = UtilManagerC()
//            let result = utilManager!.writeFile(ACCOUNT_XML_FILE, andFileContent: xmlContent)
//            
//            return result
//        } else {
            return false
//        }
    }
    
    @objc static func createAccount(email: String, password: String, subs: String, cld: String) -> Bool {
        if (email.isEmpty || password.isEmpty) {
            return false
        }
        
        for account in arrAccounts {
            if account.getEmail() == email {
                return false
            }
        }
        
        let account:Account = Account()
        
        //let isCreated = account.createAccount(email: email, password: password)
        let isCreated = account.createAccount(email: email, password: password, subs: subs, cld: cld)
        if isCreated {
            arrAccounts.append(account)
            let accountInfoXml = AccountInfoXml()
            let xmlContent = accountInfoXml.makeHeader(accountsList: arrAccounts, isFile: true)
            
            let utilManager = UtilManagerC()
            let result = utilManager!.writeFile(ACCOUNT_XML_FILE, andFileContent: xmlContent)
            
            //self.getAccounts()
            
            return result
        } else {
            return false
        }
    }
    
    @objc static func decryptAndValidateEncPriKey(password: String,rsaEncPriKey: String) -> Bool
    {
        let priKey: String = CipherAes.aesDecryptBase64(key: password, encData: rsaEncPriKey)
        if priKey.isEmpty{
            return false
        }
        else{
            if CipherRsa.isValidPrivateKey(priKey: priKey) {
                return true
            } else {
                return false
            }
        }
    }
    
    @objc static func getAccountFullInfo(email: String, password: String) -> Account?{
        print("In get account full info")
        if (email.isEmpty || password.isEmpty) {
            return nil
        }
        
        for account in arrAccounts {
            print("account email: \(account.getEmail())")
            
            if email == account.getEmail() {
                print("account password: \(password)")
                let priKey: String = CipherAes.aesDecryptBase64(key: password, encData: account.rsaEncPriKey)
                if priKey.isEmpty {
                    return nil
                } else {
                    if CipherRsa.isValidPrivateKey(priKey: priKey) {
                        account.rsaPriKey = priKey
                        return account
                    } else {
                        return account
                    }
                }
            }
        }
        
        return nil
    }

}
