//
//  LoginRequestDTO.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


struct LoginRequestDTO: Encodable {
    let parameter: String
    let password: String
    let deviceId: String
}

struct RefreshTokenRequestDTO: Encodable {
    let refreshToken: String
}
