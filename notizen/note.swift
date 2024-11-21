import Foundation

struct Note: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
}
