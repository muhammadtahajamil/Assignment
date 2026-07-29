import Foundation

class GroupInfoXml: NSObject, XMLParserDelegate {
    let NODE_ID: String = "id"
    let NODE_NAME: String = "name"
    let NODE_RSA_PUB_KEY = "rsa_public_key"
    let NODE_ENC_RSA_PRI_KEY = "enc_rsa_private_key"
    let NODE_GROUPS = "groups"
    let NODE_GROUP = "group"
    let NODE_OWNER = "owner"
    let NODE_USERS = "users"
    let NODE_USER = "user"
    let NODE_ENC_WRAPPING = "enc_wrapping_key"
    
    let XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" +
        "<!DOCTYPE groups><groups version=\"1\">"
    let XML_FOOTER = "</groups>"

    //reusable method type veriales (do not touch)
    var currentElement: String = ""
    var passGroupData: Bool = false
    var passUserData: Bool = false
    var passOwnerData: Bool = false
    
    var curAccount: Account?
    var curGroup: Group?
    var arrGroups = [Group]()
    
    override init() {
        
    }

    //parser methods
    func parse(xmlBody: String, isFile: Bool) -> [Group] {
        var xmlBodyStr = xmlBody
        if !isFile {
            xmlBodyStr = XML_HEADER + xmlBody + XML_FOOTER
        }
        let xmlData = Data(xmlBodyStr.utf8)
        
        let xmlParser = XMLParser(data: xmlData)
        xmlParser.delegate = self
        let success = xmlParser.parse()
        if success {
            print("parse success!")
            print(currentElement)
        } else {
            print("parse failure!")
        }
        
        return arrGroups
    }

    //MARK: XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        
        // start element
        if elementName == NODE_GROUP {
            curGroup = Group()
            passGroupData = true
        } else if elementName == NODE_USER {
            curAccount = Account()
            passUserData = true
        } else if elementName == NODE_OWNER {
            if !passUserData {
                curGroup?.owner = Account()
                passOwnerData = true
            }
        }
        
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
        if elementName == NODE_GROUP {
            if curGroup != nil {
                arrGroups.append(curGroup!)
            }
            passGroupData = false
        } else if elementName == NODE_USER {
            if curGroup != nil {
                if curAccount != nil {
                    curGroup?.arrMembers.append(curAccount!)
                }
            }
            passUserData = false
        } else if elementName == NODE_OWNER {
            passOwnerData = false
        }
    }

    func parser(_ parser: XMLParser, foundCharacters content: String) {
        if passOwnerData {
            if !passUserData {
                switch currentElement {
                case NODE_ID:
//                    curGroup?.owner?.getId() = content
                    break;
                    
                case NODE_ENC_WRAPPING:
                    if (curGroup != nil && curGroup?.owner != nil) {
                        curGroup?.owner?.encWrapKey = curGroup!.owner!.encWrapKey + content
                    }
                    
                default:
                    print(content)
                }
            }
            
        } else if passUserData {
            switch currentElement {
            case NODE_ID:
//                curAccount?.getId() = content
                break;
                
            case NODE_ENC_WRAPPING:
                if curAccount != nil {
                    curAccount?.encWrapKey = curAccount!.encWrapKey + content
                }
                
            default:
                print(content)
            }
        } else if passGroupData {
            //ready content for codable struct
            switch currentElement {
            case NODE_ID:
//                curGroup?.getId() = content
                break;
                
            case NODE_NAME:
//                curGroup?.getEmail() = content
                break;
                
                
            case NODE_RSA_PUB_KEY:
                if (curGroup != nil) {
                    curGroup?.rsaPubKey = curGroup!.rsaPubKey + content
                }
                
            case NODE_ENC_RSA_PRI_KEY:
                if (curGroup != nil) {
                    curGroup?.rsaEncPriKey = curGroup!.rsaEncPriKey + content
                }
                            
            default:
                print(content)
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
    
    func makeHeader(arrItemList: [Group], isFile: Bool) -> String {
        var result: String = ""
       
        for group in arrItemList {
            let id = String(format: "<%@>%@</%@>", NODE_NAME, group.getId(), NODE_NAME)
            let pubKey = String(format: "<%@>%@</%@>", NODE_RSA_PUB_KEY, group.rsaPubKey, NODE_RSA_PUB_KEY)
            let encPriKey = String(format: "<%@>%@</%@>", NODE_ENC_RSA_PRI_KEY, group.rsaEncPriKey, NODE_ENC_RSA_PRI_KEY)
            
            var members = ""
            for account in group.arrMembers {
                
            }
            
            
        }
        
        if isFile {
            result = String(format: "%@%@%@", XML_HEADER, result, XML_FOOTER)
        }
        
        return result
    }
}
