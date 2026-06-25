import Foundation
import SwiftData

@Model
final class PhysiqueEntry {
    var id: UUID
    var date: Date
    var bodyWeight: Double
    var photoData: Data?
    var notes: String
    
    // Manual body measurements (in inches or cm, depending on preferences)
    var height: Double?
    var chest: Double?
    var waist: Double?
    var hips: Double?
    var biceps: Double?
    var thighs: Double?

    init(id: UUID = UUID(), date: Date = Date(), bodyWeight: Double = 0.0, photoData: Data? = nil, notes: String = "", height: Double? = nil, chest: Double? = nil, waist: Double? = nil, hips: Double? = nil, biceps: Double? = nil, thighs: Double? = nil) {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.photoData = photoData
        self.notes = notes
        self.height = height
        self.chest = chest
        self.waist = waist
        self.hips = hips
        self.biceps = biceps
        self.thighs = thighs
    }
}
