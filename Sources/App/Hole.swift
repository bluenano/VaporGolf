import Vapor
import FluentPostgreSQL

// weak entity
// cannot be uniquely identified without the id of a scorecard
// Scorecard.ID, tee, holeNumber uniquely identify a hole in the db

final class Hole: Codable {
    
    var id: Int?
    var holeNumber: Int // typically 1-18
    var tee: String
    var par: Int // typically 3-5
    var handicap: Int // typically 1-18
    var yardage: Int 
    
    var scorecardID: Scorecard.ID
    
    init(holeNumber: Int, tee: String, par: Int,
         handicap: Int, yardage: Int, scorecardID: Scorecard.ID) {
        self.holeNumber = holeNumber
        self.tee = tee
        self.par = par
        self.handicap = handicap
        self.yardage = yardage
        self.scorecardID = scorecardID
    }
    
}

extension Hole: PostgreSQLModel {}
extension Hole: Migration {}
extension Hole: Content {}
extension Hole: Parameter {}

extension Hole {
    var scorecard: Parent<Hole, Scorecard> {
        return parent(\.scorecardID)
    }
    
    var holeNumberStr: String {
        return String(holeNumber)
    }
    
    var parStr: String {
        return String(par)
    }
    
    var handicapStr: String {
        return String(handicap)
    }
    
    var yardageStr: String {
        return String(yardage)
    }
    
}
