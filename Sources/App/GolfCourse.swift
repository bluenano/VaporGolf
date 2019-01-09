import Vapor
import FluentPostgreSQL

final class GolfCourse: Codable {
    
    var id: Int?
    var name: String
    var streetAddress: String
    var city: String
    var state: String
    var phoneNumber: String
    
    init(name: String, streetAddress: String, city: String,
         state: String, phoneNumber: String) {
        self.name = name
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.phoneNumber = phoneNumber
    }

}

extension GolfCourse: PostgreSQLModel {}
extension GolfCourse: Migration {}
extension GolfCourse: Content {}
extension GolfCourse: Parameter {}

extension GolfCourse {
    var scorecards: Children<GolfCourse, Scorecard> {
        return children(\.golfCourseID)
    }
}
