import Vapor
import FluentPostgreSQL

final class GolfCourse: Codable {
    
    var id: Int?
    var name: String
    var address: String
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
}

extension GolfCourse: PostgreSQLModel {}
extension GolfCourse: Migration {}
extension GolfCourse: Content {}
