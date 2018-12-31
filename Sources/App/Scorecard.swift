import Vapor
import FluentSQLite

final class Scorecard: Codable {
    
    var id: Int?
}

extension Scorecard: SQLiteModel {}
extension Scorecard: Migration {}
