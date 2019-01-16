import Vapor
import FluentPostgreSQL

final class Tee: Codable {
    var id: Int?
    var name: String
    var golfCourseID: GolfCourse.ID
    
    init(name: String, golfCourseID: GolfCourse.ID) {
        self.name = name
        self.golfCourseID = golfCourseID
    }
}

extension Tee: PostgreSQLModel {}
extension Tee: Content {}
extension Tee: Parameter {}

extension Tee: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
    -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.golfCourseID, to: \GolfCourse.id)
        }
    }
}

extension Tee {
    var golfCourse: Parent<Tee, GolfCourse> {
        return parent(\.golfCourseID)
    }
}

extension Tee {
    var holes: Children<Tee, Hole> {
        return children(\.teeID)
    }
    var scores: Children<Tee, Score> {
        return children(\.teeID)
    }
}


