//
//  VaultInfo.swift
//  iosvault
//
//  Created by admin on 8/24/21.
//

import Foundation

@objc class VaultInfo : NSObject {
    @objc var filename: String = ""
    @objc var headerInfo: String = ""
    
    override init() {
    }
    
    init(filename: String, headerInfo: String) {
        self.filename = filename
        self.headerInfo = headerInfo
    }
}
