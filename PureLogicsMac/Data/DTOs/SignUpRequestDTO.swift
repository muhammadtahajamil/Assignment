//
//  SignUpRequestDTO.swift
//  PureLogicsMac
//
//  Created by Apple on 07/08/2026.
//

import Foundation

struct SignUpRequestDTO: Encodable {
    let parameter: String
    let password: String
    let proCode: String?
}

