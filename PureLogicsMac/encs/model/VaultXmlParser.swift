import Foundation

@objc class VaultXmlParser: NSObject, XMLParserDelegate {
    let NODE_HEADER = "header"
    let NODE_ID: String = "id"
    let NODE_KEY: String = "key"
    let NODE_SHARED: String = "shared"
    
    let NODE_OWNER_ID = "owner"
    let NODE_FOLDER_PUBLIC_KEY = "publickey"
    let NODE_FOLDER_ENC_PRIVATE_KEY = "privatekey"
    let NODE_OWNER_ENC_WRAPPING_KEY = "wrappingkey"
    let XML_PREAMBLE = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
    

    // The following three variables are used to store the state of the xml parsing used in delegates below.
    @objc var currentElement: String = ""
    @objc var passData: Bool = false
    @objc var currentFileEncInfo: FileEncInfo?
        
    override init() {
        
    }

    //parser methods
    @objc func parse(xmlBody: String) -> FileEncInfo? {
        var xmlBodyStr = xmlBody
        xmlBodyStr = XML_PREAMBLE + xmlBody
        
        // Reset state variables:
        currentElement = ""
        passData = false
        currentFileEncInfo = nil
        
        let xmlData = Data(xmlBodyStr.utf8)
        
        let xmlParser = XMLParser(data: xmlData)
        xmlParser.delegate = self
        let success: Bool = xmlParser.parse()
        if success {
            if currentFileEncInfo == nil {
                return nil;
            }
            
            if currentFileEncInfo!.id.isEmpty || currentFileEncInfo!.aesEncKey!.length == 0 || currentFileEncInfo!.shared == "" {
                return nil
            }
            
            if currentFileEncInfo!.shared != "yes" && currentFileEncInfo!.shared != "no" {
                return nil
            }
            
            if currentFileEncInfo!.shared == "yes" {
                if currentFileEncInfo!.ownerId.isEmpty ||
                    currentFileEncInfo!.folderPublicKey.isEmpty ||
                    currentFileEncInfo!.folderEncPrivateKey.isEmpty ||
                    currentFileEncInfo!.ownerEncWrappingKey.isEmpty {
                    return nil
                }
            }
            
            return currentFileEncInfo
        } else {
            return nil
        }
    }

    //MARK: XMLParserDelegate methods
    @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        
        // start element
        if elementName == NODE_HEADER {
            currentFileEncInfo = FileEncInfo()
        }
        passData = true
    }

    @objc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
        if elementName == NODE_HEADER {
            
        }
        passData = false
    }

    @objc func parser(_ parser: XMLParser, foundCharacters content: String) {
        
        if passData {
            //ready content for codable struct
            switch currentElement {
            case NODE_ID:
                currentFileEncInfo?.id = content
                
            case NODE_KEY:
                currentFileEncInfo?.aesEncKey = content as! NSMutableString
                
            case NODE_SHARED:
                currentFileEncInfo?.shared = content
                
            case NODE_OWNER_ID:
                currentFileEncInfo?.ownerId = content
                
            case NODE_FOLDER_PUBLIC_KEY:
                currentFileEncInfo?.folderPublicKey = content
            
            case NODE_FOLDER_ENC_PRIVATE_KEY:
                currentFileEncInfo?.folderEncPrivateKey = content
                
            case NODE_OWNER_ENC_WRAPPING_KEY:
                currentFileEncInfo?.ownerEncWrappingKey = content
                
            default:
                break;
            }
        }
    }

    @objc func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
    
    @objc func getHeaderXml(fileEncInfo: FileEncInfo?) -> String {
        if (fileEncInfo == nil) {
            return ""
        } else {
            let id = String(format: "<%@>%@</%@>", NODE_ID, fileEncInfo!.id, NODE_ID)
            let key = String(format: "<%@>%@</%@>", NODE_KEY, fileEncInfo!.aesEncKey!, NODE_KEY)
            let shared = String(format: "<%@>%@</%@>", NODE_SHARED, fileEncInfo!.shared, NODE_SHARED)
            let ownerId = String(format: "<%@>%@</%@>", NODE_OWNER_ID, fileEncInfo!.ownerId, NODE_OWNER_ID)
            let folderPublicKey = String(format: "<%@>%@</%@>", NODE_FOLDER_PUBLIC_KEY, fileEncInfo!.folderPublicKey, NODE_FOLDER_PUBLIC_KEY)
            let folderEncPrivateKey = String(format: "<%@>%@</%@>", NODE_FOLDER_ENC_PRIVATE_KEY, fileEncInfo!.folderEncPrivateKey, NODE_FOLDER_ENC_PRIVATE_KEY)
            let ownerEncWrappingKey = String(format: "<%@>%@</%@>", NODE_OWNER_ENC_WRAPPING_KEY, fileEncInfo!.ownerEncWrappingKey, NODE_OWNER_ENC_WRAPPING_KEY)
           
            let headerXml = String(format: "<%@>%@%@%@%@%@%@%@</%@>", NODE_HEADER, id, key, shared, ownerId, folderPublicKey, folderEncPrivateKey, ownerEncWrappingKey, NODE_HEADER)
            return headerXml
        }
    }
    
}

