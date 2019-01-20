import Vapor
import FluentPostgreSQL

final class Hole: Codable {
    
    var id: Int?
    var holeNumber: Int // typically 1-18
    var par: Int // typically 3-5
    var handicap: Int // typically 1-18
    var yardage: Int 
    
    var teeID: Tee.ID
    
    init(holeNumber: Int, par: Int,
         handicap: Int, yardage: Int,
         teeID: Tee.ID) {
        self.holeNumber = holeNumber
        self.par = par
        self.handicap = handicap
        self.yardage = yardage
        self.teeID = teeID
    }
    
}

extension Hole: PostgreSQLModel {}
extension Hole: Content {}
extension Hole: Parameter {}

extension Hole: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.teeID, to: \Tee.id)
            }
    }
}

extension Hole {
    var tee: Parent<Hole, Tee> {
        return parent(\.teeID)
    }
}

extension Hole {
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
