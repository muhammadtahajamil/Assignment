import Foundation

@objc class FileEncInfo : NSObject{
    @objc var id = ""
    @objc var aesKey: NSMutableData? = NSMutableData()
    @objc var aesEncKey: NSMutableString? = NSMutableString()
    
    @objc var shared = ""
    @objc var ownerId = "";
    @objc var folderPublicKey = "";
    @objc var folderEncPrivateKey = "";
    @objc var ownerEncWrappingKey = "";
    
    override init() {
        super.init()
    }
    
    @objc init(account: Account) {
        id = account.getId()
        
        var success = OpenSSL_AESKeyHelper_Wrapper.generateAes256Key(&aesKey)
        if success {
            success = OpenSSL_Helper_Wrapper.rsaEncryptBase64Encode(aesKey as Data?, derEncodedPublicKey: account.getDerEncodedPublicKey(), output: &aesEncKey)
            if !success {
                // For the time being, it's assumed that this scenario will not happen.
                aesEncKey = NSMutableString()
            }
        } else {
            // For the time being, it's assumed that this scenario will not happen.
            aesKey = NSMutableData()
        }
        
        shared = "no";
    }
}
