//
//  SecretInfoXml.swift
//  iosvault
//
//  Created by admin on 8/23/21.
//

import Foundation

class SecretInfoXml: NSObject, XMLParserDelegate {
    
    let NODE_EMAIl: String = "email"
    let NODE_PASSWORD = "password"
    let NODE_NAME = "name"
    let NODE_DATE = "date"
    let NODE_USER = "account"
    
    let XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" +
        "<!DOCTYPE accounts><accounts version=\"1\">"
    let XML_FOOTER = "</accounts>"
    
    //reusable method type veriales (do not touch)
    var currentElement: String = ""
    var passData: Bool = false
    
    var curSecret: Secret?
        
    override init() {
        
    }

    //parser methods
    func parse(xmlBody: String, isFile: Bool) -> Secret? {
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
        
        return curSecret
    }

    //MARK: XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        
        // start element
        if elementName == NODE_USER {
            curSecret = Secret()
            passData = true
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
        if elementName == NODE_USER {
            passData = false
        }
    }

    func parser(_ parser: XMLParser, foundCharacters content: String) {
        
        if passData {
            //ready content for codable struct
            switch currentElement {
                            
            case NODE_EMAIl:
                curSecret?.email = content
                
            case NODE_PASSWORD:
                if (curSecret != nil) {
                    curSecret?.password = content
                }
                
            case NODE_NAME:
                if (curSecret != nil) {
                    curSecret?.name = content
                }
            
            case NODE_DATE:
                if (curSecret != nil) {
                    curSecret?.date = content
                }
                            
            default:
                print(content)
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
    
    func makeHeader(secret: Secret, isFile: Bool) -> String {
        var result: String = ""
        
        let email = String(format: "<%@>%@</%@>", NODE_EMAIl, secret.email, NODE_EMAIl)
        let password = String(format: "<%@>%@</%@>", NODE_PASSWORD, secret.password, NODE_PASSWORD)
        let name = String(format: "<%@>%@</%@>", NODE_NAME, secret.name, NODE_NAME)
        let date = String(format: "<%@>%@</%@>", NODE_DATE, secret.date, NODE_DATE)
        let item = String(format: "<%@>%@%@%@%@</%@>", NODE_USER, email, password, name, date, NODE_USER)
        
        if isFile {
            result = String(format: "%@%@%@", XML_HEADER, item, XML_FOOTER)
        }
        
        return result
    }
}	
