//
//  UserSessionStore.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


@MainActor
@Observable final class UserSessionStore {
    var currentUser: UserAuthInfo?
    var authData : AuthResponseDTO?
    var isAuthenticated: Bool { currentUser != nil }
}
