//
//  LinkedDevicesView.swift
//  PureLogicsMac
//
//  Created by Apple on 13/08/2026.
//

import SwiftUI

struct LinkedDevicesView: View {
    @Environment(UserSessionStore.self) private var sessionStore

    var body: some View {
        LinkedDevicesStoryboardContent(
            sessionStore: sessionStore
        )
    }
}

private struct LinkedDevicesStoryboardContent: View {
    @Environment(AuthNavigationStore.self) private var authNavigation
    @State var linkedDevicesVM : LinkeddevicesVM
    

    private let baseSize = CGSize(width: 800, height: 626)

   
    
    @State private var subscriptionStatus: String = "Free (2 Devices Allowed)"
    @State private var isCurrentMacId: String = "" // ID of current Mac device

    var onDismiss: (() -> Void)?

    init(sessionStore: UserSessionStore) {
        let apiClient = DefaultAPIClient(environment: .development)
        let authRemoteDataSource = DefaultAuthRemoteDataSource(apiClient: apiClient)
        let authRepository = DefaultAuthRepository(remoteDataSource: authRemoteDataSource)
        let authUseCase = LoginUseCase(repository: authRepository)
        
        _linkedDevicesVM = State(wrappedValue: LinkeddevicesVM(sessionStore: sessionStore, userCase: authUseCase))
    }

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
    }

    private var storyboardLayout: some View {
        ZStack(alignment: .topLeading) {
            // Background Image matching storyboard
            Image("Settings - General Settings - Copy")
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height)

            // Close Button top-right
            closeButton

            // Header Section
            headerNavigation

            // Main Content Area
            contentSection
            
            // Loading Overlay
            if linkedDevicesVM.isLoading {
                loadingOverlay
            }
        }
    }

    private var closeButton: some View {
        Button {
            onDismiss?()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(botmColor)
                Image("close_icon")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 20, height: 20)
        .position(x: 780, y: 20)
    }

    private var headerNavigation: some View {
        HStack(spacing: 8) {
            Image("general_settings_icon")
                .resizable()
                .frame(width: 20, height: 20)

            Text("Linked Devices")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: 180, height: 25, alignment: .leading)
        .position(x: 100, y: 40)
    }

    private var contentSection: some View {
        ZStack(alignment: .topLeading) {
            // Subscription Info Stack
            HStack(spacing: 6) {
                Text("Subscription:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(redTitleColor)

                Text(subscriptionStatus)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(redTitleColor)
            }
            .frame(width: 350, height: 20, alignment: .leading)
            .position(x: 435, y: 97)

            // Subtitle Description
            descriptionStack
                .position(x: 495, y: 133)

            // Devices Table (Header + Scrollable Rows)
            tableSection
                .position(x: 510.5, y: 260)

            // Action Buttons Row
            actionButtons
        }
    }

    private var descriptionStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text("These devices are linked with your account. You have")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)

                Text("1 more device(s)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)

                Text("left to link")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)
            }

            HStack(spacing: 2) {
                Text("with your")
                    .font(.system(size: 13))
                    .foregroundStyle(textColor)

                Text("subscription.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
            }
        }
        .frame(width: 498, height: 38, alignment: .leading)
    }

    private var tableSection: some View {
        VStack(spacing: 0) {
            // Table Header
            tableHeader
                .frame(width: 501, height: 36)

            // Table Rows List
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(Array(linkedDevicesVM.devices.enumerated()), id: \.element.id) { index, device in
                        tableRow(index: index + 1, device: device)
                    }
                }
            }
            .frame(width: 501, height: 162)
            .background(Color.white)
        }
    }

    private var tableHeader: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(lightGrayHeaderColor)

            HStack(spacing: 0) {
                Text("Sr.No.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
                    .frame(width: 70, alignment: .center)

                Divider()
                    .frame(height: 36)

                Text("Device Name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
                    .padding(.leading, 15)
                    .frame(width: 270, alignment: .leading)

                Divider()
                    .frame(height: 36)

                Text("Device Type")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
                    .padding(.leading, 15)
                    .frame(width: 140, alignment: .leading)
            }
        }
    }

    private func tableRow(index: Int, device: DeviceDTO) -> some View {
        let isSelected = linkedDevicesVM.selectedDeviceId == device.id

        return Button {
            linkedDevicesVM.selectedDeviceId = device.id
        } label: {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(isSelected ? selectedRowColor : Color.white)

                HStack(spacing: 0) {
                    Text("\(index)")
                        .font(.system(size: 12))
                        .foregroundStyle(textColor)
                        .frame(width: 70, alignment: .center)

                    Divider()
                        .frame(height: 30)

                    HStack(spacing: 4) {
                        Text(device.name)
                            .font(.system(size: 12))
                            .foregroundStyle(textColor)

                        if device.id == isCurrentMacId {
                            Text("(This MAC)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.leading, 15)
                    .frame(width: 270, alignment: .leading)

                    Divider()
                        .frame(height: 30)

                    Text(device.platform)
                        .font(.system(size: 12))
                        .foregroundStyle(textColor)
                        .padding(.leading, 15)
                        .frame(width: 140, alignment: .leading)
                }

                VStack {
                    Spacer()
                    Divider()
                }
            }
            .frame(height: 30)
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        ZStack(alignment: .topLeading) {
            // Remove Button
            Button {
                if let selectedId = linkedDevicesVM.selectedDeviceId {
                    linkedDevicesVM.devices.removeAll { $0.id == selectedId }
                    linkedDevicesVM.selectedDeviceId = nil
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(linkedDevicesVM.selectedDeviceId != nil ? removeButtonRed : removeButtonRed.opacity(0.5))

                    Text("Remove From List")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .disabled(linkedDevicesVM.selectedDeviceId == nil)
            .frame(width: 140, height: 35)
            .position(x: 690, y: 388)

            // Upgrade Button
            Button {
                print("Upgrade Now tapped")
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(upgradeGreenColor)

                    Text("Upgrade Now!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 140, height: 35)
            .position(x: 330, y: 388)

            // Login Button
            Button {
                print("Login Now tapped")
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(blueButtonColor)

                    Text("Login Now!")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 140, height: 35)
            .position(x: 330, y: 503)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.18))

            ProgressView()
                .controlSize(.large)
                .frame(width: 50, height: 50)
        }
        .frame(width: 362, height: 430)
        .position(x: 360, y: 333)
    }

    // Color definitions matching sample storyboard named colors
    private var textColor: Color {
        Color(red: 0.333, green: 0.333, blue: 0.333)
    }

    private var botmColor: Color {
        Color(red: 0.118, green: 0.294, blue: 0.580)
    }

    private var redTitleColor: Color {
        Color(red: 0.886, green: 0.341, blue: 0.298)
    }

    private var lightGrayHeaderColor: Color {
        Color(red: 0.863, green: 0.863, blue: 0.863)
    }

    private var selectedRowColor: Color {
        Color(red: 0.775, green: 0.875, blue: 0.981)
    }

    private var removeButtonRed: Color {
        Color(red: 0.831, green: 0.153, blue: 0.075)
    }

    private var upgradeGreenColor: Color {
        Color(red: 0.078, green: 0.729, blue: 0.027)
    }

    private var blueButtonColor: Color {
        Color(red: 0.035, green: 0.588, blue: 0.973)
    }
}

#Preview("Linked Devices Screen", traits: .fixedLayout(width: 840, height: 626)) {
    LinkedDevicesView()
        .frame(width: 840, height: 626)
        .environment(UserSessionStore())
        .environment(AuthNavigationStore())
}
