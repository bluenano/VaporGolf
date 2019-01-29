import Vapor
import FluentPostgreSQL

final class Score: Codable {
   
    var id: Int?
    var date: Date
    var strokesPerHole: [Int]
    var puttsPerHole: [Int]
    var greensInRegulation: [Bool]
    var fairwaysHit: [Bool]
    var golferID: Golfer.ID
    var teeID: Tee.ID
    
    init(date: Date, strokesPerHole: [Int],
         puttsPerHole: [Int], greensInRegulation: [Bool],
         fairwaysHit: [Bool], golferID: Golfer.ID, teeID: Tee.ID) {
        self.date = date
        self.strokesPerHole = strokesPerHole
        self.puttsPerHole = puttsPerHole
        self.greensInRegulation = greensInRegulation
        self.fairwaysHit = fairwaysHit
        self.golferID = golferID
        self.teeID = teeID
    }
    
}

extension Score: PostgreSQLModel {}
extension Score: Content {}
extension Score: Parameter {}

extension Score {
    var golfer: Parent<Score, Golfer> {
        return parent(\.golferID)
    }
    var tee: Parent<Score, Tee> {
        return parent(\.teeID)
    }
}

extension Score {
    var scoreImage: Children<Score, ScoreImage> {
        return children(\.scoreID)
    }
}

extension Score: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.golferID, to: \Golfer.id)
                builder.reference(from: \.teeID, to: \Tee.id)
            }
    }
}

extension Score {
    var totalScore: Int {
        var total: Int = 0
        for score in strokesPerHole {
            total += score
        }
        return total
    }
    
    var totalScoreStr: String {
        return String(totalScore)
    }
}
