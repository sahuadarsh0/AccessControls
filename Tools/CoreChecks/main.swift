import RouteBarCore
import Foundation

enum CheckFailure: Error, CustomStringConvertible {
    case failed(String)

    var description: String {
        switch self {
        case .failed(let message):
            return message
        }
    }
}

func check(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else {
        throw CheckFailure.failed(message)
    }
}

do {
    let webURL = try RouteItemValidator.normalizedURLString("example.com/calculator/help")
    try check(webURL == "https://example.com/calculator/help", "Web URL normalization failed")

    let deepLink = try RouteItemValidator.normalizedURLString("calculator://open")
    try check(deepLink == "calculator://open", "Deep link preservation failed")

    do {
        _ = try RouteItemValidator.normalizedURLString("https:///missing-host")
        throw CheckFailure.failed("Invalid HTTP URL was accepted")
    } catch RouteValidationError.invalidURL {
    }

    let normalizedGreen = try RouteItemValidator.normalizedColorHex("2f9e44")
    try check(normalizedGreen == "#2F9E44", "Color normalization failed")

    let normalizedBlue = try RouteItemValidator.normalizedColorHex("#4f7cac")
    try check(normalizedBlue == "#4F7CAC", "Hashed color normalization failed")

    let directoryURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let fileURL = directoryURL.appendingPathComponent("items.json")
    let store = RouteStore(fileURL: fileURL)
    let item = RouteItem(
        kind: .link,
        title: "Calculator",
        colorHex: "#2F9E44",
        urlString: "https://example.com"
    )

    try store.upsert(item)

    let reloadedStore = RouteStore(fileURL: fileURL)
    try reloadedStore.load()

    try check(reloadedStore.items.count == 1, "Store round trip item count failed")
    try check(reloadedStore.items.first?.title == "Calculator", "Store round trip title failed")
    try check(reloadedStore.items.first?.urlString == "https://example.com", "Store round trip URL failed")

    try reloadedStore.delete(id: item.id)

    let deletedStore = RouteStore(fileURL: fileURL)
    try deletedStore.load()
    try check(deletedStore.items.isEmpty, "Store delete persistence failed")

    print("RouteBarCoreChecks passed")
} catch {
    fputs("RouteBarCoreChecks failed: \(error)\n", stderr)
    exit(1)
}
