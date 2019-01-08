import Vapor
import FluentPostgreSQL

final class Score: Codable {
   
    var id: Int?
    var date: Date
    var strokesPerHole: [Int]
    var puttsPerHole: [Int]
    var greensInRegulation: [Bool]
    var golferID: Golfer.ID
    var scorecardID: Scorecard.ID
    
    init(date: Date, strokesPerHole: [Int],
         puttsPerHole: [Int], greensInRegulation: [Bool],
         golferID: Golfer.ID, scorecardID: Scorecard.ID) {
        self.date = date
        self.strokesPerHole = strokesPerHole
        self.puttsPerHole = puttsPerHole
        self.greensInRegulation = greensInRegulation
        self.golferID = golferID
        self.scorecardID = scorecardID
    }
    
}

extension Score: PostgreSQLModel {}
extension Score: Content {}
extension Score: Parameter {}

// access the parent of a score (Golfer)
extension Score {
    var golfer: Parent<Score, Golfer> {
        return parent(\.golferID)
    }
    
    var golfCourse: Parent<Score, GolfCourse> {
        return parent(\.scorecardID)
    }
}

// add foreign key constraint to Score table
// now we must make sure that we create Golfer table
// before the Score table

extension Score: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.golferID, to: \Golfer.id)
                builder.reference(from: \.scorecardID, to: \Scorecard.id)
            }
    }
}

// add computed property for total score
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
