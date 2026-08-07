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
    private var gracePeriodDays: Int = 0
    private var passwordSha256Hash: Data?
    private var derEncodedPrivateKeySha256Hash: Data?
    
    // Account Details
    private var subscription: String = "Free"
    private var defaultCloud: String = "None"
    private var numberOfDevices: Int = 0
    private var cardExpiryDate: String = "empty"
    private var cardLastFourDigits: String = "empty"
    private var purchaseDate: String = "empty"
    private var expiryDate: String = "empty"
    private var activationKey: String = "empty"
    
    private var serverCurrentDate: String = ""
    
    private var aesEncryptedBase64EncodedAccountDetails: String = ""
    
    private var passwordSalt: String = ""
    private var subscriptionPlatform: String = ""
    
    
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
        self.numberOfDevices = other.numberOfDevices
        self.cardExpiryDate = other.cardExpiryDate
        self.cardLastFourDigits = other.cardLastFourDigits
        self.purchaseDate = other.purchaseDate
        self.expiryDate = other.expiryDate
        self.activationKey = other.activationKey
        self.subscriptionPlatform = other.subscriptionPlatform
        self.passwordSalt = other.passwordSalt
        self.gracePeriodDays = other.gracePeriodDays
        
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
    @objc func getNumberOfDevices() -> Int { return numberOfDevices }
    @objc func getCardExpiry() -> String { return cardExpiryDate }
    @objc func getCardLastFourDigits() -> String { return cardLastFourDigits }
    @objc func getSubscriptionDate() -> String { return purchaseDate }
    @objc func getSubscriptionExpiryDate() -> String { return expiryDate }
    @objc func getActivationCode() -> String { return activationKey }
    @objc func getSubscriptionPlatform() -> String { return subscriptionPlatform }
    @objc func getAesEncryptedBase64EncodedAccountDetails() -> String { return aesEncryptedBase64EncodedAccountDetails }
    @objc func getServerCurrentDate() -> String { return serverCurrentDate }
    @objc func getGracePeriodDays() -> Int { return gracePeriodDays }
    
    @objc func getpasswordSalt() -> String { return passwordSalt }
    
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
    @objc func setNumberOfDevices(_ numberOfDevices: Int) { self.numberOfDevices = numberOfDevices }
    @objc func setCardExpiry(_ cardExpiryDate: String) { self.cardExpiryDate = cardExpiryDate }
    @objc func setCardLastFourDigits(_ cardLastFourDigits: String) { self.cardLastFourDigits = cardLastFourDigits }
    @objc func setSubscriptionDate(_ purchaseDate: String) { self.purchaseDate = purchaseDate }
    @objc func setSubscriptionExpiryDate(_ expiryDate: String) { self.expiryDate = expiryDate }
    @objc func setActivationCode(_ activationKey: String) { self.activationKey = activationKey }
    @objc func setSubscriptionPlatform(_ subscriptionPlatform: String) { self.subscriptionPlatform = subscriptionPlatform }
    @objc func setAesEncryptedBase64EncodedAccountDetails(_ aesEncryptedBase64EncodedAccountDetails: String) { self.aesEncryptedBase64EncodedAccountDetails = aesEncryptedBase64EncodedAccountDetails }
    @objc func setServerCurrentDate(_ serverCurrentDate: String) { self.serverCurrentDate = serverCurrentDate }
    @objc func setpasswordSalt(_ passwordSalt: String) { self.passwordSalt = passwordSalt }
    @objc func setGracePeriodDays(_ gracePeriodDays: Int) { self.gracePeriodDays = gracePeriodDays }
}
