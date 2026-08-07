//
//  UserSessionStore.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//
import Observation

@MainActor
@Observable final class UserSessionStore {
    var currentUser: UserAuthInfo?
    var authData : AuthResponseDTO?
    var deviceList : [DeviceDTO]?
    
    var isAuthenticated: Bool { return authData != nil }
    
    func logout() {
        currentUser = nil
        authData = nil
        deviceList = nil
        URLCache.shared.removeAllCachedResponses()
    }
}
