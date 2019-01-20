import Vapor
import FluentPostgreSQL

final class ScoreImage: Codable {
    var id: Int?
    var imageData: File?
    var scoreID: Score.ID
    
    init(imageData: File?, scoreID: Score.ID) {
        self.imageData = imageData
        self.scoreID = scoreID
    }
    
}

extension ScoreImage: PostgreSQLModel {}
extension ScoreImage: Content {}
extension ScoreImage: Parameter {}

extension ScoreImage {
    var score: Parent<ScoreImage, Score> {
        return parent(\.scoreID)
    }
}

extension ScoreImage: Migration {
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.scoreID, to: \ScoreImage.id)
            }
    }
}
