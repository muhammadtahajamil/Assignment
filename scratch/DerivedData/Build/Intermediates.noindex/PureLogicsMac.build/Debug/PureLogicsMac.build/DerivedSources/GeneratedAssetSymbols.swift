import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Keyboard" asset catalog image resource.
    static let keyboard = DeveloperToolsSupport.ImageResource(name: "Keyboard", bundle: resourceBundle)

    /// The "Sign_InBackGroung" asset catalog image resource.
    static let signInBackGroung = DeveloperToolsSupport.ImageResource(name: "Sign_InBackGroung", bundle: resourceBundle)

    /// The "features 1 1" asset catalog image resource.
    static let features11 = DeveloperToolsSupport.ImageResource(name: "features 1 1", bundle: resourceBundle)

    /// The "ic_round-home" asset catalog image resource.
    static let icRoundHome = DeveloperToolsSupport.ImageResource(name: "ic_round-home", bundle: resourceBundle)

    /// The "upgrade icon 1" asset catalog image resource.
    static let upgradeIcon1 = DeveloperToolsSupport.ImageResource(name: "upgrade icon 1", bundle: resourceBundle)

}

