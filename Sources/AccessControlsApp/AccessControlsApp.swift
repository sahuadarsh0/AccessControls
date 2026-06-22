import AppKit
import SwiftUI

@main
struct AccessControlsApp: App {
    @StateObject private var model = AccessControlsViewModel()

    init() {
        AccessBrandIcon.installApplicationIcon()
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverContent(model: model)
        } label: {
            Image(nsImage: AccessBrandIcon.menuBarImage)
                .renderingMode(.original)
                .help("Access Controls")
        }
        .menuBarExtraStyle(.window)
    }
}
