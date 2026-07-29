//
//  GroupManager.swift
//  iosvault
//
//  Created by admin on 8/23/21.
//

import Foundation

@objc class ShareGroupManager : NSObject {
    static let SHARE_XML_FILE = "share.xml"
    
    @objc nonisolated(unsafe) static var arrGroups = [Group]()
    
    @objc static func getGroups() {
        do {
            let utilManager = UtilManagerC()
            var contents = utilManager!.readFile(SHARE_XML_FILE)
            if contents == nil || contents!.isEmpty {
                arrGroups = [];
            } else {
                let groupInfoXml: GroupInfoXml = GroupInfoXml()
                arrGroups = groupInfoXml.parse(xmlBody: contents!, isFile: true)
            }
            print("parsed")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc static func getGroupById(id: String) -> Group? {
        for group in arrGroups {
            if id == group.getId() {
                return group
            }
        }
        
        return nil
    }
}
