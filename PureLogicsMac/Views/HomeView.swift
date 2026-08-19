//
//  HomeView.swift
//  PureLogicsMac
//
//  Created by Apple on 14/08/2026.

//
//  HomeView.swift
//  PureLogicsMac
//
//  Created by Apple on 14/08/2026.

import SwiftUI

/// Main Bottom Navigation Tabs
enum HomeBottomTab: Int, CaseIterable,Identifiable {
    case home = 0
    case cloud = 1
    case sync = 2
    case share = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .cloud: return "Cloud"
        case .sync: return "Sync"
        case .share: return "Share"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "Home_Icon"
        case .cloud: return "main_cloud_icon"
        case .sync: return "main_sync_icon"
        case .share: return "main_share_icon"
        }
    }
}

struct HomeView: View {
    @Environment(UserSessionStore.self) private var sessionStore
//    var onSignOut: (() -> Void)? = nil

    var body: some View {
        HomeStoryboardContent(sessionStore: sessionStore)
    }
        
}

private struct HomeStoryboardContent: View {
    @Environment(AuthNavigationStore.self) private var authNavigation
    @State private var homeViewModel: HomeViewModel
    
    init(sessionStore :UserSessionStore){
        let apiClient = DefaultAPIClient(environment: .development)
        let authRemoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
        let authRepository = DefaultAuthRepository(remoteDataSource: authRemoteDataSource)
        let authUseCase = LoginUseCase(repository: authRepository)
        
        _homeViewModel = State(wrappedValue: HomeViewModel(useCase: authUseCase, sessionStore: sessionStore))
    }
    
    private let baseSize = CGSize(width: 800, height: 626)

    //TODO: Start from here move these below to viewModel
    // MARK: - State Management
    

    // Feature Toggles (Cloud Settings Tab)
    @State private var desktopLockerEnabled: Bool = true
    @State private var dropboxLockerEnabled: Bool = true
    @State private var googleDriveLockerEnabled: Bool = true
    @State private var oneDriveLockerEnabled: Bool = true

    @State private var desktopAutoOpen: Bool = true
    @State private var dropboxAutoOpen: Bool = true
    @State private var googleDriveAutoOpen: Bool = true
    @State private var oneDriveAutoOpen: Bool = true

    // Sync Tab State
    @State private var isSyncEnabled: Bool = true
    @State private var selectedSyncLocker: String = "Desktop Locker (Sync: OFF)"

    // Sidebar Selections
    @State private var selectedSecretOption: String? = nil
    @State private var selectedSupportOption: String? = nil

    var onSignOut: (() -> Void)?


    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / baseSize.width, proxy.size.height / baseSize.height)

            storyboardLayout
                .frame(width: baseSize.width, height: baseSize.height)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(
                    width: baseSize.width * scale,
                    height: baseSize.height * scale,
                    alignment: .topLeading
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(minWidth: baseSize.width, minHeight: baseSize.height)
        .onAppear {
            print("Taha here in home")
        }
        
    }

    private var storyboardLayout: some View {
        ZStack(alignment: .topLeading) {
            // Main Background
            Image("homebackgrounnd")
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height)

            // Top Header Navigation Bar
            topNavigationHeader

            // Left Content Container (Switching according to selected bottom tab)
            ZStack {
                switch homeViewModel.selectedTab {
                case .home:
                    mainFeaturesTabContent
                case .cloud:
                    cloudSettingsTabContent
                case .sync:
                    syncSettingsTabContent
                case .share:
                    shareSettingsTabContent
                }
            }
            .frame(width: 533, height: 403)
            .position(x: 273.5, y: 323)

            // Right Sidebar Section (Secrets & Support Settings)
            rightSidebarSection
                .frame(width: 200, height: 700)
                .position(x: 670, y: 310)
                
            

            // Bottom 4-Tab Navigation Bar
            bottomTabBar
                .position(x: 272.5, y: 568)

            // Opening Locker Modal Popup Overlay
            if homeViewModel.isOpeningLocker {
                openingLockerOverlay
            }

            // Global Loading Indicator Overlay
            if homeViewModel.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - 1. Top Header Navigation
    private var topNavigationHeader: some View {
        ZStack(alignment: .topLeading) {
            // Main Features Header Icon & Label
            HStack(spacing: 6) {
                Image("ic_round-home")
                    .resizable()
                    .frame(width: 26, height: 26)

                Text("Main Features")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textColor)
            }
            .frame(width: 120, height: 25, alignment: .leading)
            .position(x: 70, y: 107)

            // Version Identifier Button
            Button("Version 10.1.1") {}
                .buttonStyle(UnderlineTextButtonStyle(color: .white, font: .system(size: 13)))
                .frame(width: 85, height: 16, alignment: .leading)
                .position(x: 167.5, y: 69)

            // Subscription Information & Upgrade Action
            HStack(spacing: 4) {
                Text("Subscription:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textColor)

                Text("Pro (Infinite GB)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)

                Button("Upgrade") {}
                    .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 13, weight: .medium)))
            }
            .frame(width: 240, height: 20, alignment: .leading)
            .position(x: 410, y: 107)

            // Additional Features Header Label
            HStack(spacing: 6) {
                Image("features 1 1")
                    .resizable()
                    .frame(width: 18, height: 20)

                Text("Additional Features")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textColor)
            }
            .frame(width: 145, height: 20, alignment: .leading)
            .position(x: 629.5, y: 107)

            // Sign Out Top Right Icon Button
            Button {
                onSignOut?()
            } label: {
                Image("signout_btn_normal")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .position(x: 783, y: 15)
        }
    }

    // MARK: - 2. TAB 0: Home / Main Features Content
    private var mainFeaturesTabContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Desktop Locker Row
                lockerRow(
                    iconName: "desktop_locker",
                    title: "Desktop Locker",
                    subtitle: "To Encrypt files locally",
                    actionTitle: "Decrypt",
                    actionColor: greenColor,
                    action: { openLockerProgressFlow() }
                )
                Divider()

                // Mobile Locker Row
                lockerRow(
                    iconName: "mobile_locker",
                    title: "Mobile Locker",
                    subtitle: "To Encrypt & Sync for Mobile",
                    actionTitle: "Open",
                    actionColor: redColor,
                    action: { openLockerProgressFlow() }
                )
                Divider()

                // Dropbox Locker Row
                lockerRow(
                    iconName: "dropbox_locker_disable",
                    title: "Dropbox Locker",
                    subtitle: "To Encrypt files in Dropbox",
                    actionTitle: "Decrypt",
                    actionColor: redColor,
                    action: { openLockerProgressFlow() }
                )
                Divider()

                // Google Drive Locker Row
                lockerRow(
                    iconName: "google_drive_locker_disable",
                    title: "Google Drive Locker",
                    subtitle: "To Encrypt files in Google Drive",
                    actionTitle: "Login",
                    actionColor: blueButtonColor,
                    action: {}
                )
                Divider()

                // OneDrive Locker Row
                lockerRow(
                    iconName: "onedrive_locker_disable",
                    title: "OneDrive Locker",
                    subtitle: "To Encrypt files in OneDrive",
                    actionTitle: "Install",
                    actionColor: blueButtonColor,
                    action: {}
                )
            }
        }
    }

    private func lockerRow(
        iconName: String,
        title: String,
        subtitle: String,
        actionTitle: String,
        actionColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 20) {
            Image(iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.leading, 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(textColor)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
            }

            Spacer()

            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(actionColor)

                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 125, height: 33)
            .padding(.trailing, 37)
        }
        .frame(height: 103)
    }

    // MARK: - 3. TAB 1: Cloud Locker Settings Content
    private var cloudSettingsTabContent: some View {
        ZStack(alignment: .topLeading) {
            Image("Cloud BG")
                .resizable()
                .frame(width: 530, height: 403)

            VStack(alignment: .leading, spacing: 14) {
                Text("Selected Lockers show up in the Main Features. Auto Open shows the Locker when you login automatically.")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
                    .frame(width: 460, alignment: .leading)
                    .padding(.top, 12)

                // Header Labels
                HStack(spacing: 0) {
                    Text("Show on Main")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 150, alignment: .leading)

                    Text("Auto Open")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 110, alignment: .leading)

                    Text("Encrypted Location")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(textColor)

                // Checkbox Matrix List
                VStack(spacing: 12) {
                    cloudSettingRow(
                        title: "Desktop Locker (local)",
                        isEnabled: $desktopLockerEnabled,
                        autoOpen: $desktopAutoOpen
                    )
                    cloudSettingRow(
                        title: "Dropbox Locker",
                        isEnabled: $dropboxLockerEnabled,
                        autoOpen: $dropboxAutoOpen
                    )
                    cloudSettingRow(
                        title: "Google Drive Locker",
                        isEnabled: $googleDriveLockerEnabled,
                        autoOpen: $googleDriveAutoOpen
                    )
                    cloudSettingRow(
                        title: "OneDrive Locker",
                        isEnabled: $oneDriveLockerEnabled,
                        autoOpen: $oneDriveAutoOpen
                    )
                }
            }
            .padding(.horizontal, 30)
        }
    }

    private func cloudSettingRow(
        title: String,
        isEnabled: Binding<Bool>,
        autoOpen: Binding<Bool>
    ) -> some View {
        HStack(spacing: 0) {
            Toggle(title, isOn: isEnabled)
                .toggleStyle(.checkbox)
                .font(.system(size: 13))
                .foregroundStyle(textColor)
                .frame(width: 170, alignment: .leading)

            Toggle("", isOn: autoOpen)
                .toggleStyle(.checkbox)
                .frame(width: 90, alignment: .leading)

            Button("Open") {}
                .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 13)))
        }
    }

    // MARK: - 4. TAB 2: Sync Settings Content
    private var syncSettingsTabContent: some View {
        ZStack(alignment: .topLeading) {
            Image("Sync BG")
                .resizable()
                .frame(width: 530, height: 403)

            VStack(alignment: .leading, spacing: 16) {
                Text("Choose a default Locker for syncing your Secrets across all devices. When Sync is off, data is stored locally in Desktop Locker.")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
                    .frame(width: 472, alignment: .leading)
                    .padding(.top, 12)

                HStack(spacing: 12) {
                    Text("Sync")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(textColor)

                    Toggle("", isOn: $isSyncEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)

                    Text(isSyncEnabled ? "ON" : "OFF")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isSyncEnabled ? greenColor : .gray)
                }

                // Default Sync Picker
                Picker("", selection: $selectedSyncLocker) {
                    Text("Desktop Locker (Sync: OFF)").tag("Desktop Locker (Sync: OFF)")
                    Text("Dropbox Locker (Sync: ON)").tag("Dropbox Locker (Sync: ON)")
                    Text("Google Drive Locker (Sync: ON)").tag("Google Drive Locker (Sync: ON)")
                    Text("OneDrive Locker (Sync: ON)").tag("OneDrive Locker (Sync: ON)")
                }
                .pickerStyle(.menu)
                .frame(width: 293)

                Text("Download the Apps for devices below using link or QR Code.")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
                    .padding(.top, 10)

                // Store App Links
                HStack(spacing: 30) {
                    Button {} label: {
                        Image("App store button")
                            .resizable()
                            .frame(width: 130, height: 39)
                    }
                    .buttonStyle(.plain)

                    Button {} label: {
                        Image("Google Play button")
                            .resizable()
                            .frame(width: 130, height: 39)
                    }
                    .buttonStyle(.plain)

                    Button {} label: {
                        Image("Windows button")
                            .resizable()
                            .frame(width: 130, height: 39)
                    }
                    .buttonStyle(.plain)
                }

                // QR Code Section
                HStack(spacing: 21) {
                    Image("QR_Code")
                        .resizable()
                        .frame(width: 110, height: 112)

                    Text("Use your device to scan this QR Code to go to the relevant App Store to download the App on your device.")
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)
                        .frame(width: 180, alignment: .leading)
                }
            }
            .padding(.horizontal, 30)
        }
    }

    // MARK: - 5. TAB 3: Share Settings Content
    private var shareSettingsTabContent: some View {
        ZStack(alignment: .topLeading) {
            Image("Share BG")
                .resizable()
                .frame(width: 530, height: 403)

            VStack(alignment: .leading, spacing: 18) {
                Text("Securely share your encrypted folder(s) by giving permissions to those folder(s).")
                    .font(.system(size: 14))
                    .foregroundStyle(textColor)
                    .frame(width: 470, alignment: .leading)
                    .padding(.top, 12)

                // 1. Set Permissions
                shareOptionRow(
                    iconName: "give_permission",
                    title: "Set Permissions",
                    description: "Allow other users to access your folder(s) without compromising security.",
                    buttonTitle: "Give Permission",
                    action: {}
                )

                Divider()

                // 2. Manage Permissions
                shareOptionRow(
                    iconName: "edit_permission",
                    title: "Manage Permissions",
                    description: "Here you can edit the permissions to the existing permitted users.",
                    buttonTitle: "View/Edit",
                    action: {}
                )

                Divider()

                // 3. Create/Edit Groups
                shareOptionRow(
                    iconName: "main_share_icon",
                    title: "Create/Edit Groups",
                    description: "For easy sharing, create a group of users to give access to your folder(s).",
                    buttonTitle: "Create/Edit",
                    isComingSoon: true,
                    action: {}
                )
            }
            .padding(.horizontal, 30)
        }
    }

    private func shareOptionRow(
        iconName: String,
        title: String,
        description: String,
        buttonTitle: String,
        isComingSoon: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image(iconName)
                .resizable()
                .frame(width: 45, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(textColor)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)
                    .frame(width: 250, alignment: .leading)
            }

            Spacer()

            VStack(spacing: 4) {
                Button(action: action) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(blueButtonColor)

                        Text(buttonTitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 114, height: 34)

                if isComingSoon {
                    Text("(Coming Soon)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(textColor)
                }
            }
        }
    }

    // MARK: - 6. Bottom 4-Tab Navigation Bar
    private var bottomTabBar: some View {
        VStack{
            Divider()
                .frame(width: 550)
                .offset(y:10)
            
            ZStack {
                HStack(spacing: 0) {
                    ForEach(HomeBottomTab.allCases) { tab in
                        Button {
                            homeViewModel.selectedTab = tab
                            homeViewModel.hoveredTab = nil
                        } label: {
                            ZStack {
                                
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: tab == .home ? 10 : 0,
                                    bottomTrailingRadius: tab == .share ? 10 : 0,
                                    topTrailingRadius: 0
                                )
                                .fill(homeViewModel.selectedTab == tab ? Color.white : silverColor)
                                
                                VStack(spacing: 6) {
                                    Image(tab.iconName)
                                        .resizable()
                                        .frame(width: 38, height: 38)
                                    
                                    Text(tab.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle((homeViewModel.selectedTab == tab || homeViewModel.hoveredTab == tab) ? linkBlue : textColor)
                                }
                                // Draw the indicator line on the left edge
                                
                                .overlay(alignment: .leading) {
                                    if homeViewModel.hoveredTab == tab && homeViewModel.selectedTab != tab {
                                        Image("main_select_line_icon")
                                            .resizable()
                                            .frame(width: 6, height: 80)
                                        
                                            .offset(x: -46,y: -4)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .onHover { isHovered in
                            if isHovered {
                                if tab != homeViewModel.selectedTab {
                                    homeViewModel.hoveredTab = tab
                                }
                            } else if homeViewModel.hoveredTab == tab {
                                homeViewModel.hoveredTab = nil
                            }
                        }
                        .frame(width: 133, height: 97)
                        if tab != .share {
                            Divider()
                                .frame(height: 96)
                        }
                    }
                }
                .frame(width: 535, height: 97)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 10,
                    bottomTrailingRadius: 10,
                    topTrailingRadius: 0
                ))
            }
        }
    }

    // MARK: - 7. Right Sidebar (Secrets & Support Settings)
    private var rightSidebarSection: some View {
        VStack(spacing: 4) {
            // Secrets Panel Header
            HStack(spacing: 6) {
                Image("main_wallet_icon")
                    .resizable()
                    .frame(width: 24, height: 22)
                Text("Secrets")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)

                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(width: 250, height: 36)

            Divider()
                .frame(width: 250)

            // Secrets Items List
            VStack(spacing: 0) {
                sidebarItemRow(image: "tree_view_wallets_icon", title: "Wallets", isSelected: selectedSecretOption == "Wallets") {
                    selectedSecretOption = "Wallets"
                }
                sidebarItemRow(image: "tree_view_password_icon", title: "Cards", isSelected: selectedSecretOption == "Cards") {
                    selectedSecretOption = "Cards"
                }
                sidebarItemRow(image: "tree_view_notes_icon", title: "Notes", isSelected: selectedSecretOption == "Notes") {
                    selectedSecretOption = "Notes"
                }
            }
            .frame(width: 250, height: 120)

            // Support & Settings Header
            HStack(spacing: 6) {
                Image("setting")
                    .resizable()
                    .frame(width: 22, height: 21)

                Text("Support & Settings")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)

                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(width: 250, height: 45)
            Divider()
            // Support Options List
            VStack(spacing: 0) {
                sidebarItemRow(image: "setting_yellow_icon", title: "Settings", isSelected: selectedSupportOption == "Settings") {
                    selectedSupportOption = "Settings"
                }
                sidebarItemRow(image: "upgrade", title: "Buy Pro", isSelected: selectedSupportOption == "Buy Pro") {
                    selectedSupportOption = "Buy Pro"
//                    authNavigation.push(.linkedDevices)
//                    add linked devices here
                }
                sidebarItemRow(image: "enterProCode", title: "Enter Pro Code", isSelected: selectedSupportOption == "Enter Pro Code") {
                    selectedSupportOption = "Enter Pro Code"
                }
                sidebarItemRow(image: "support_about_icon", title: "About", isSelected: selectedSupportOption == "About") {
                    selectedSupportOption = "About"
                }
                sidebarItemRow(image: "feedback", title: "Feedback", isSelected: selectedSupportOption == "Feedback") {
                    selectedSupportOption = "Feedback"
                }
                
            }
            .frame(width: 250, height: 160)
            .offset(y:16)
        }
        .frame(width: 250)
    }

    private func sidebarItemRow(image:String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(isSelected ? selectedRowColor : Color.white)

                HStack(spacing: 6) {
                    Image(image)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.horizontal, 10)
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)
                        .padding(.leading, 15)

                    Spacer()
                }

                VStack {
                    Spacer()
                    Divider()
                }
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 8. Opening Locker Popup Overlay (`2Ex-gZ-rrG`)
    private var openingLockerOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.35))
                .ignoresSafeArea()

            ZStack(alignment: .topLeading) {
                Image("LockingView")
                    .resizable()
                    .frame(width: 370, height: 481)

                VStack(spacing: 25) {
                    Text("Opening your Locker")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 18)
                        .padding(.top, 13)

                    Image("lock_open")
                        .resizable()
                        .frame(width: 55, height: 55)
                        .padding(.top, 25)

                    Text("Opening your Locker")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(textColor)

                    ProgressView(value: homeViewModel.lockerOpeningProgress, total: 100)
                        .progressViewStyle(.linear)
                        .frame(width: 320)

                    Text("Please Wait! Your encrypted files are being made available in a virtual drive for access.")
                        .font(.system(size: 13))
                        .foregroundStyle(textColor)
                        .multilineTextAlignment(.center)
                        .frame(width: 280)

                    Button("Cancel") {
                        homeViewModel.isOpeningLocker = false
                    }
                    .buttonStyle(UnderlineTextButtonStyle(color: linkBlue, font: .system(size: 13)))
                    .padding(.top, 10)
                }
            }
            .frame(width: 370, height: 481)
        }
        .frame(width: 800, height: 626)
    }

    private func openLockerProgressFlow() {
        homeViewModel.isOpeningLocker = true
        homeViewModel.lockerOpeningProgress = 10.0
        withAnimation(.linear(duration: 1.5)) {
            homeViewModel.lockerOpeningProgress = 100.0
        }
    }

    // MARK: - 9. Global Loading Overlay (`Spinner_5`)
    private var loadingOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.20))

            ProgressView()
                .controlSize(.large)
                .frame(width: 50, height: 50)
        }
        .frame(width: 800, height: 626)
    }

    // MARK: - Colors Palette
    private var textColor: Color { Color(red: 0.333, green: 0.333, blue: 0.333) }
    private var linkBlue: Color { Color(red: 0.01, green: 0.26, blue: 0.52) }
    private var greenColor: Color { Color(red: 0.310, green: 0.733, blue: 0.282) }
    private var blueButtonColor: Color { Color(red: 0.035, green: 0.588, blue: 0.973) }
    private var redColor: Color { Color(red: 0.886, green: 0.341, blue: 0.298) }
    private var selectedRowColor: Color { Color(red: 0.775, green: 0.875, blue: 0.981) }
    private var silverColor: Color { Color(red: 0.83, green: 0.83, blue: 0.85) }
}

private struct UnderlineTextButtonStyle: ButtonStyle {
    let color: Color
    let font: Font

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(color.opacity(configuration.isPressed ? 0.7 : 1))
            .underline()
            .contentShape(Rectangle())
    }
}

#Preview("Home Screen (Full Tabs)", traits: .fixedLayout(width: 840, height: 626)) {
    HomeView()
        .frame(width: 840, height: 626)
//        .environment(UserSessionStore())
//        .environment(AuthNavigationStore())
}


#Preview {
    HomeView()
}
