//
//  AppDependencyConatainer.swift
//  PureLogicsMac
//
//  Created by Apple on 12/08/2026.
//
import Foundation

@MainActor
protocol UserSessionStoring : AnyObject {
    var authData : AuthResponseDTO? { get set }
    var deviceList : [DeviceDTO]? {get set}
    var verificationData : SignUpVerificationData? {get set}
    func logout()
}
extension UserSessionStore: UserSessionStoring {}

@MainActor
final class AppDependencyConatainer {
    let sessionStore : UserSessionStore
    init() {
        self.sessionStore = UserSessionStore()
    }
}
