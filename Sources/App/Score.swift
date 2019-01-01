import Vapor
import FluentPostgreSQL

final class Score: Codable {
   
    var id: Int?
}

extension Score: PostgreSQLModel {}
extension Score: Migration {}
extension Score: Content {}
extension Score: Parameter {}
