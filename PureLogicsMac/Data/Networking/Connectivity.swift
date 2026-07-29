//
//  Connectivity.swift
//  PureLogicsMac
//
//  Created by Apple on 14/07/2026.
//


import Network
import Foundation

final class Connectivity {
    @MainActor static let shared = Connectivity()
    
    // Restrict the monitor strictly to the Wi-Fi interface
    private let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private let queue = DispatchQueue(label: "WiFiMonitorQueue")
    
    // The property you will check
    private(set) var isConnectedToWiFi: Bool = false
    
    @MainActor private static func updateWiFiStatus(isConnected: Bool) {
        shared.isConnectedToWiFi = isConnected
    }
    
    private init() {
        monitor.pathUpdateHandler = { path in
            Task { @MainActor in
                Connectivity.updateWiFiStatus(isConnected: (path.status == .satisfied))
            }
        }
        monitor.start(queue: queue)
    }
    deinit {
        monitor.cancel()
    }
}

