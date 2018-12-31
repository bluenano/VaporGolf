import Vapor
import FluentSQLite

final class Score: Codable {
   
    var id: Int?
}

extension Score: SQLiteModel {}
extension Score: Migration {}

