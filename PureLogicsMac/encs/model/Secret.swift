//
//  Secret.swift
//  iosvault
//
//  Created by admin on 8/23/21.
//

import Foundation

@objc class Secret : NSObject {
    @objc var email: String = ""
    @objc var password: String = ""
    @objc var name: String = ""
    @objc var date: String = ""
    
    override init() {
        
    }
    
    init(email: String, password: String, name: String, date: String) {
        self.email = email
        self.password = password
        self.name = name
        self.date = date
    }
}
