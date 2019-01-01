import Vapor
import FluentPostgreSQL

final class Hole: Codable {
    
    var id: Int?
    
}

extension Hole: PostgreSQLModel {}
extension Hole: Migration {}
extension Hole: Content {}
extension Hole: Parameter {}
