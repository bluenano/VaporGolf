import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: Int?
    var token: String
    var golferID: Golfer.ID
    
    init(token: String, golferID: Golfer.ID) {
        self.token = token
        self.golferID = golferID
    }
}

extension Token: PostgreSQLModel {}
extension Token: Content {}

extension Token: Migration {
    static func prepare(on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.golferID, to: \Golfer.id)
            }
    }
}

extension Token {
    static func generate(for golfer: Golfer) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(
            token: random.base64EncodedString(),
            golferID: golfer.requireID())
    }
}

extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \Token.golferID
    typealias UserType = Golfer
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
