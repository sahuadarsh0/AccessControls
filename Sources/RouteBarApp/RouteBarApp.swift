import AppKit
import SwiftUI

@main
struct RouteBarApp: App {
    @StateObject private var model = RouteBarViewModel()

    init() {
        RouteBrandIcon.installApplicationIcon()
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverContent(model: model)
        } label: {
            Image(nsImage: RouteBrandIcon.menuBarImage)
                .renderingMode(.original)
                .help("Route Bar")
        }
        .menuBarExtraStyle(.window)
    }
}
