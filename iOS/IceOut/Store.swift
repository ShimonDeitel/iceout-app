import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [IceEvent] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier keeps every seeded entry visible without hitting the paywall on first launch.
    static let freeTierLimit = 20

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("IceOut", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeTierLimit
    }

    func add(_ entry: IceEvent) {
        guard canAddMore else { return }
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: IceEvent) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: IceEvent) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([IceEvent].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData()
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [IceEvent] {
        [
        IceEvent(bodyName: "Ice Event 1", kind: "Ice Event 1", notes: "Ice Event 1"),
        IceEvent(bodyName: "Ice Event 2", kind: "Ice Event 2", notes: "Ice Event 2"),
        IceEvent(bodyName: "Ice Event 3", kind: "Ice Event 3", notes: "Ice Event 3"),
        IceEvent(bodyName: "Ice Event 4", kind: "Ice Event 4", notes: "Ice Event 4")
        ]
    }
}
