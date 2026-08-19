//
//  HomeViewModel.swift
//  PureLogicsMac
//
//  Created by Apple on 15/08/2026.

@MainActor
@Observable final class HomeViewModel {
    
    //Shared Variables
    var selectedTab: HomeBottomTab = .home
    var hoveredTab: HomeBottomTab? = nil
    var isLoading: Bool = false
    var isOpeningLocker: Bool = false
    var lockerOpeningProgress: Double = 50.0
    
    
    //private variables
    private let useCase: LoginUseCase
    private let sessionStore: UserSessionStore
    
    
    //Initializer
    init(useCase:LoginUseCase, sessionStore: UserSessionStore) {
        self.useCase = useCase
        self.sessionStore = sessionStore
        
    }
    
    //Shared functions
    func getDefualtValues(){
        
        /*
         "defaultCloud" : "None",
         "onExitLock" : false,
         "onOpenLockerShowTip" : false,
         "onExitMinToMenuBar" : false,
         "passwordToAccessSettings" : false,
         "openSecretOnLogin" : false,
         "showInDock" : true,
         "passwordToAccessSecrets" : false,
         "sampleSecret" : "0",
         "passwordToAccessSharing" : false,
         "autoOpen" : "Desktop",
         "showLimitedPopupAgain" : true,
         "disableDropboxLocker" : false,
         "disableGDLocker" : false,
         "disableODLocker" : false
         */
        
    }
    
    //Helping Private Functions
}
