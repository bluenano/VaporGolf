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
extension Scorecard: Migration {}
extension Scorecard: Content {}
extension Scorecard: Parameter {}

extension Scorecard {
    var golfCourse: Parent<Scorecard, GolfCourse> {
        return parent(\.golfCourseID)
    }
}
