//
//  LinkeddevicesVM.swift
//  PureLogicsMac
//
//  Created by Apple on 13/08/2026.
//

@MainActor
@Observable class LinkeddevicesVM {
    
    //Shared Variables
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var selectedDeviceId: String? = nil
    
    
    var devices: [DeviceDTO]
    
    
    //Private Variables
    private let sessionStore : UserSessionStore
    private let userCase : LoginUseCase
    
    //Initializer
    init (sessionStore: UserSessionStore, userCase :LoginUseCase) {
        self.sessionStore = sessionStore
        self.userCase = userCase
        self.devices = sessionStore.deviceList!
    }
    
    //Shared functions
    
    
    //Helping Private Functions
}


//Shared Variables
//private variables
//Initializer
//Shared functions
//Helping Private Functions
