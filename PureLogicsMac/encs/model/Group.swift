//
//  Group.swift
//  iosvault
//
//  Created by admin on 8/23/21.
//

import Foundation

@objc class Group : BaseUser {
    @objc var wrappingKey: String = ""
    @objc var owner: BaseUser? = nil
    @objc var arrMembers = [BaseUser]();
    
    override init() {
        super.init()
    }
    
    @objc func getMember(userId: String) -> BaseUser? {
        for member in arrMembers {
            if member.getId() == userId {
                return member;
            }
        }
        
        return nil
    }
    
}
