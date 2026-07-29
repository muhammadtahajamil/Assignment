import Foundation

//class VaultInfoXml: NSObject, XMLParserDelegate {
//    
//    let NODE_NAME = "name"
//    let NODE_HEADER = "header"
//    let NODE_USER = "item"
//    
//    let XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" +
//        "<!DOCTYPE items><items version=\"1\">"
//    let XML_FOOTER = "</items>"
//    
//    //reusable method type veriales (do not touch)
//    var currentElement: String = ""
//    var passData: Bool = false
//    
//    var curItem: VaultInfo?
//    var arrItems = [VaultInfo]()
//        
//    override init() {
//        
//    }
//
//    //parser methods
//    func parse(xmlBody: String, isFile: Bool) -> [VaultInfo] {
//        var xmlBodyStr = xmlBody
//        if !isFile {
//            xmlBodyStr = XML_HEADER + xmlBody + XML_FOOTER
//        }
//        let xmlData = Data(xmlBodyStr.utf8)
//        
//        let xmlParser = XMLParser(data: xmlData)
//        xmlParser.delegate = self
//        let success = xmlParser.parse()
//        if success {
//            print("parse success!")
//            print(currentElement)
//        } else {
//            print("parse failure!")
//        }
//        
//        return arrItems
//    }
//
//    //MARK: XMLParserDelegate methods
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
//        currentElement = elementName
//        
//        // start element
//        if elementName == NODE_USER {
//            curItem = VaultInfo()
//            passData = true
//        }
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        currentElement = ""
//        if elementName == NODE_USER {
//            passData = false
//            
//            if curItem != nil {
//                arrItems.append(curItem!)
//            }
//        }
//    }
//
//    func parser(_ parser: XMLParser, foundCharacters content: String) {
//        
//        if passData {
//            //ready content for codable struct
//            switch currentElement {
//            
//            case NODE_NAME:
//                if (curItem != nil) {
//                    curItem?.filename = content
//                }
//            
//            case NODE_HEADER:
//                if (curItem != nil) {
//                    curItem?.headerInfo = content
//                }
//                            
//            default:
//                print(content)
//            }
//        }
//    }
//
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        print("failure error: ", parseError)
//    }
//    
//    func makeHeader(vaultInfos: [VaultInfo], isFile: Bool) -> String {
//        var result: String = ""
//        
//        for vaultInfo in vaultInfos {
//            let name = String(format: "<%@>%@</%@>", NODE_NAME, vaultInfo.filename, NODE_NAME)
//            let header = String(format: "<%@>%@</%@>", NODE_HEADER, vaultInfo.headerInfo, NODE_HEADER)
//            let item = String(format: "<%@>%@%@</%@>", NODE_USER, name, header, NODE_USER)
//            result += item
//        }
//        
//        if isFile {
//            result = String(format: "%@%@%@", XML_HEADER, result, XML_FOOTER)
//        }
//        
//        return result
//    }
//}
