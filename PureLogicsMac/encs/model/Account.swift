import Foundation

@objc class Account: BaseUser {
    let MYVAULT_ID_LEN = 20
    
    override init() {
        super.init()
    }
    
    @objc func createAccount(email: String, password: String, subs: String, cld: String) -> Bool {
        // check parameters
        if (email.isEmpty || password.isEmpty) {
            return false
        }
        
        self.setEmail(email)
        self.setId(UserDefaults.standard.string(forKey:"uniqueId") ?? "")
        self.setBase64DerEncodedPublicKey(UserDefaults.standard.string(forKey:"base64DerEncodedPublicKey") ?? "")
        self.setBase64EncodedPrivateKeySalt(UserDefaults.standard.string(forKey:"base64EncodedPrivateKeySalt") ?? "")
        self.setBase64EncodedSecurePrivateKey(UserDefaults.standard.string(forKey:"base64EncodedSecurePrivateKey") ?? "")
        self.setPrivateKeyIterations(UserDefaults.standard.integer(forKey:"privateKeyKdfIterations"))
        self.setPasswordIterations(UserDefaults.standard.integer(forKey:"passwordHashKdfIterations"))
        let passwordSHA256 = OpenSSL_SHA256Helper_Wrapper.computeSHA256(password.data(using: .utf8))
        let derEncodedPrivateKey = UserDefaults.standard.data(forKey:"derEncodedPrivateKey")
        let derEncodedPrivateKeySha256Hash = OpenSSL_SHA256Helper_Wrapper.computeSHA256(derEncodedPrivateKey)
        let userStatus = UserDefaults.standard.string(forKey:"userStatus") ?? ""
        let numberOfDevices = UserDefaults.standard.string(forKey:"numberOfDevices") ?? ""
        let subscriptionDate = UserDefaults.standard.string(forKey:"subscriptionDate") ?? ""
        let cardExpiry = UserDefaults.standard.string(forKey:"cardExpiry") ?? ""
        let cardLastFourDigits = UserDefaults.standard.string(forKey:"cardLastFourDigits") ?? ""
        let subscriptionExpiry = UserDefaults.standard.string(forKey:"subscriptionExpiry") ?? ""
        let activationCode = UserDefaults.standard.string(forKey:"activationCode") ?? ""
        var aesEncryptedBase64EncodedAccountDetails : NSString?
        var result = [SecureAccount_Wrapper.encryptUserAccountDetails(email, passwordSha256Hash: passwordSHA256, derEncodedPrivateKeySha256Hash: derEncodedPrivateKeySha256Hash, subscription: subs, defaultCloud: cld, userStatus: userStatus, numberOfDevices: numberOfDevices, cardExpiry: cardExpiry, cardLastFourDigits: cardLastFourDigits, subscriptionDate: subscriptionDate, subscriptionExpiryDate: subscriptionExpiry, activationCode: activationCode, aesEncryptedBase64EncodedAccountDetails: &aesEncryptedBase64EncodedAccountDetails)]
        
        self.setAesEncryptedBase64EncodedAccountDetails(aesEncryptedBase64EncodedAccountDetails! as String)
                
        self.cld = cld
        self.subs = subs
        
        return true
    }
    
}
