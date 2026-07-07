import Foundation

struct IceEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var bodyName: String
    var kind: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), bodyName: String = "", kind: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.bodyName = bodyName
        self.kind = kind
        self.notes = notes
    }
}
