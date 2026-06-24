import Foundation
import SwiftData

@Model
final class PhysiqueEntry {
    var id: UUID
    var date: Date
    var bodyWeight: Double
    var photoData: Data?
    var notes: String

    init(id: UUID = UUID(), date: Date = Date(), bodyWeight: Double = 0.0, photoData: Data? = nil, notes: String = "") {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.photoData = photoData
        self.notes = notes
    }
}
