import Vapor
import FluentSQLite

final class Hole: Codable {
    
    var id: Int?
    
}

extension Hole: SQLiteModel {}
extension Hole: Migration {}
