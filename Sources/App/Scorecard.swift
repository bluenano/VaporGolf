import Vapor
import FluentPostgreSQL

final class Scorecard: Codable {
    
    var id: Int?
}

extension Scorecard: PostgreSQLModel {}
extension Scorecard: Migration {}
extension Scorecard: Content {}
extension Scorecard: Parameter {}
