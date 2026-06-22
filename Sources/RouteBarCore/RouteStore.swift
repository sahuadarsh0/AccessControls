import Foundation

public final class RouteStore {
    public private(set) var items: [RouteItem] = []
    public let fileURL: URL

    public init(fileURL: URL = RouteStore.defaultFileURL()) {
        self.fileURL = fileURL
    }

    public static func defaultFileURL() -> URL {
        let applicationSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let fileURL = applicationSupportURL
            .appendingPathComponent("RouteBar", isDirectory: true)
            .appendingPathComponent("items.json")
        let legacyFileURL = applicationSupportURL
            .appendingPathComponent("AccessControls", isDirectory: true)
            .appendingPathComponent("items.json")

        migrateLegacyStoreIfNeeded(from: legacyFileURL, to: fileURL)
        return fileURL
    }

    private static func migrateLegacyStoreIfNeeded(from legacyFileURL: URL, to fileURL: URL) {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: fileURL.path),
              fileManager.fileExists(atPath: legacyFileURL.path)
        else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.copyItem(at: legacyFileURL, to: fileURL)
        } catch {
            // Loading will fall back to an empty store if migration is not possible.
        }
    }

    public func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            items = []
            return
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        items = try decoder.decode([RouteItem].self, from: data)
            .sorted { first, second in
                first.createdAt < second.createdAt
            }
    }

    public func save() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(items)
        try data.write(to: fileURL, options: [.atomic])
    }

    public func upsert(_ item: RouteItem) throws {
        var copy = item
        copy.updatedAt = Date()

        if let index = items.firstIndex(where: { $0.id == item.id }) {
            copy.createdAt = items[index].createdAt
            items[index] = copy
        } else {
            items.append(copy)
        }

        try save()
    }

    public func delete(id: RouteItem.ID) throws {
        items.removeAll { $0.id == id }
        try save()
    }
}
