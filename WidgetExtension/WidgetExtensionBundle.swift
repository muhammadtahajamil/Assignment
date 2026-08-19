//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Apple on 15/08/2026.
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        WidgetExtension()
        WidgetExtensionControl()
    }
}
