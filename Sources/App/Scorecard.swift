import Vapor
import FluentPostgreSQL

final class Scorecard: Codable {
    
    var id: Int?
    var tees: [String]
    var golfCourseID: GolfCourse.ID
    
    init(tees: [String], golfCourseID: GolfCourse.ID) {
        self.tees = tees
        self.golfCourseID = golfCourseID
    }
    
}

extension Scorecard: PostgreSQLModel {}
extension Scorecard: Content {}
extension Scorecard: Parameter {}

extension Scorecard: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.golfCourseID, to: \GolfCourse.id)
            }
    }
}

extension Scorecard {
    var golfCourse: Parent<Scorecard, GolfCourse> {
        return parent(\.golfCourseID)
    }
}

extension Scorecard {
    var holes: Children<Scorecard, Hole> {
        return children(\.scorecardID)
    }
    var scores: Children<Scorecard, Score> {
        return children(\.scorecardID)
    }
}
