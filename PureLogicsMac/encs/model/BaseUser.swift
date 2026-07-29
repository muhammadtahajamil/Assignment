import Foundation

@objc class BaseUser : NSObject{
    
    @objc var rsaPubKey: String = ""
    @objc var rsaPriKey: String = ""
    @objc var rsaEncPriKey: String = ""
    @objc var encWrapKey: String = ""
    @objc var shareOwner: String = ""
    
    @objc var subs: String = ""
    @objc var cld: String = ""
    
    //==============================
    
    private var id: String = ""
    private var email: String = ""
    
    private var derEncodedPublicKey: Data?
    private var derEncodedPrivateKey: Data?
    private var base64DerEncodedPublicKey: String = ""
    private var base64EncodedSecurePrivateKey: String = ""
    private var base64EncodedPrivateKeySalt: String = ""
    private var privateKeyIterations: Int = 0
    private var passwordIterations: Int = 0
    
    private var passwordSha256Hash: Data?
    private var derEncodedPrivateKeySha256Hash: Data?
    
    // Account Details
    private var subscription: String = "Free"
    private var defaultCloud: String = "None"
    private var status: String = "Active"
    private var numberOfDevices: Int = 0
    private var cardExpiry: String = "empty"
    private var cardLastFourDigits: String = "empty"
    private var subscriptionDate: String = "empty"
    private var subscriptionExpiryDate: String = "empty"
    private var activationCode: String = "empty"
    
    private var serverCurrentDate: String = ""
    
    private var aesEncryptedBase64EncodedAccountDetails: String = ""
    
    // Default initializer
    override init() {
        super.init()
    }
    
    // Copy initializer for deep copy
    @objc init(other: Account) {
        self.id = other.id
        self.email = other.email
        self.derEncodedPublicKey = other.derEncodedPublicKey
        self.derEncodedPrivateKey = other.derEncodedPrivateKey
        self.base64DerEncodedPublicKey = other.base64DerEncodedPublicKey
        self.base64EncodedSecurePrivateKey = other.base64EncodedSecurePrivateKey
        self.base64EncodedPrivateKeySalt = other.base64EncodedPrivateKeySalt
        self.privateKeyIterations = other.privateKeyIterations
        self.passwordIterations = other.passwordIterations
        self.passwordSha256Hash = other.passwordSha256Hash
        self.derEncodedPrivateKeySha256Hash = other.derEncodedPrivateKeySha256Hash
        self.subscription = other.subscription
        self.defaultCloud = other.defaultCloud
        self.status = other.status
        self.numberOfDevices = other.numberOfDevices
        self.cardExpiry = other.cardExpiry
        self.cardLastFourDigits = other.cardLastFourDigits
        self.subscriptionDate = other.subscriptionDate
        self.subscriptionExpiryDate = other.subscriptionExpiryDate
        self.activationCode = other.activationCode
        self.serverCurrentDate = other.serverCurrentDate
        self.aesEncryptedBase64EncodedAccountDetails = other.aesEncryptedBase64EncodedAccountDetails
        super.init()
    }
    
    // Getters
    @objc func getId() -> String { return id }
    @objc func getEmail() -> String { return email }
    @objc func getDerEncodedPublicKey() -> Data? { return derEncodedPublicKey }
    @objc func getDerEncodedPrivateKey() -> Data? { return derEncodedPrivateKey }
    @objc func getBase64DerEncodedPublicKey() -> String { return base64DerEncodedPublicKey }
    @objc func getBase64EncodedSecurePrivateKey() -> String { return base64EncodedSecurePrivateKey }
    @objc func getBase64EncodedPrivateKeySalt() -> String { return base64EncodedPrivateKeySalt }
    @objc func getPrivateKeyIterations() -> Int { return privateKeyIterations }
    @objc func getPasswordIterations() -> Int { return passwordIterations }
    @objc func getPasswordHash() -> Data? { return passwordSha256Hash }
    @objc func getPrivateKeyHash() -> Data? { return derEncodedPrivateKeySha256Hash }
    @objc func getSubscription() -> String { return subscription }
    @objc func getDefaultCloud() -> String { return defaultCloud }
    @objc func getStatus() -> String { return status }
    @objc func getNumberOfDevices() -> Int { return numberOfDevices }
    @objc func getCardExpiry() -> String { return cardExpiry }
    @objc func getCardLastFourDigits() -> String { return cardLastFourDigits }
    @objc func getSubscriptionDate() -> String { return subscriptionDate }
    @objc func getSubscriptionExpiryDate() -> String { return subscriptionExpiryDate }
    @objc func getActivationCode() -> String { return activationCode }
    @objc func getAesEncryptedBase64EncodedAccountDetails() -> String { return aesEncryptedBase64EncodedAccountDetails }
    @objc func getServerCurrentDate() -> String { return serverCurrentDate }
    
    // Setters
    @objc func setId(_ id: String) { self.id = id }
    @objc func setEmail(_ email: String) { self.email = email }
    @objc func setDerEncodedPublicKey(_ derEncodedPublicKey: Data?) { self.derEncodedPublicKey = derEncodedPublicKey }
    @objc func setDerEncodedPrivateKey(_ derEncodedPrivateKey: Data?) { self.derEncodedPrivateKey = derEncodedPrivateKey }
    @objc func setBase64DerEncodedPublicKey(_ base64DerEncodedPublicKey: String) { self.base64DerEncodedPublicKey = base64DerEncodedPublicKey }
    @objc func setBase64EncodedSecurePrivateKey(_ base64EncodedSecurePrivateKey: String) { self.base64EncodedSecurePrivateKey = base64EncodedSecurePrivateKey }
    @objc func setBase64EncodedPrivateKeySalt(_ base64EncodedPrivateKeySalt: String) { self.base64EncodedPrivateKeySalt = base64EncodedPrivateKeySalt }
    @objc func setPrivateKeyIterations(_ privateKeyIterations: Int) { self.privateKeyIterations = privateKeyIterations }
    @objc func setPasswordIterations(_ passwordIterations: Int) { self.passwordIterations = passwordIterations }
    @objc func setPasswordHash(_ passwordSha256Hash: Data?) { self.passwordSha256Hash = passwordSha256Hash }
    @objc func setPrivateKeyHash(_ derEncodedPrivateKeySha256Hash: Data?) { self.derEncodedPrivateKeySha256Hash = derEncodedPrivateKeySha256Hash }
    @objc func setSubscription(_ subscription: String) { self.subscription = subscription }
    @objc func setDefaultCloud(_ defaultCloud: String) { self.defaultCloud = defaultCloud }
    @objc func setStatus(_ status: String) { self.status = status }
    @objc func setNumberOfDevices(_ numberOfDevices: Int) { self.numberOfDevices = numberOfDevices }
    @objc func setCardExpiry(_ cardExpiry: String) { self.cardExpiry = cardExpiry }
    @objc func setCardLastFourDigits(_ cardLastFourDigits: String) { self.cardLastFourDigits = cardLastFourDigits }
    @objc func setSubscriptionDate(_ subscriptionDate: String) { self.subscriptionDate = subscriptionDate }
    @objc func setSubscriptionExpiryDate(_ subscriptionExpiryDate: String) { self.subscriptionExpiryDate = subscriptionExpiryDate }
    @objc func setActivationCode(_ activationCode: String) { self.activationCode = activationCode }
    @objc func setAesEncryptedBase64EncodedAccountDetails(_ aesEncryptedBase64EncodedAccountDetails: String) { self.aesEncryptedBase64EncodedAccountDetails = aesEncryptedBase64EncodedAccountDetails }
    @objc func setServerCurrentDate(_ serverCurrentDate: String) { self.serverCurrentDate = serverCurrentDate }
}
