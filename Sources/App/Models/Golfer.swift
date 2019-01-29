import Vapor
import FluentPostgreSQL
import Authentication
import Configuration

final class Golfer: Codable {
    
    var id: Int?
    var username: String
    var password: String
    var firstname: String
    var lastname: String
    var age: Int
    var gender: String
    var height: Int
    var weight: Int
    
    init(username: String, password: String,
         firstname: String, lastname: String, age: Int,
         gender: String, height: Int, weight: Int) {
        self.username = username
        self.password = password
        self.firstname = firstname
        self.lastname = lastname
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
    }
    
    final class Public: Codable {
        var id: Int?
        var username: String
        var firstname: String
        var lastname: String
        var age: Int
        var gender: String
        var height: Int
        var weight: Int
        
        init(id: Int?, username: String, firstname: String,
             lastname: String, age: Int, gender: String,
             height: Int, weight: Int) {
            self.id = id
            self.username = username
            self.firstname = firstname
            self.lastname = lastname
            self.age = age
            self.gender = gender
            self.height = height
            self.weight = weight
        }
    }
}

extension Golfer: PostgreSQLModel {}
extension Golfer: Content {}
extension Golfer: Parameter {}
extension Golfer.Public: Content {}

extension Golfer {
    var scores: Children<Golfer, Score> {
        return children(\.golferID)
    }
}

extension Golfer {
    var ageStr: String {
        return String(age)
    }
    
    var heightStr: String {
        return String(height)
    }
    
    var weightStr: String {
        return String(weight)
    }
}

extension Golfer: Migration {
    static func prepare(on connection: PostgreSQLConnection)
        -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.unique(on: \.username)
            }
    }
}

extension Golfer {
    func convertToPublic() -> Golfer.Public {
        return Golfer.Public(id: id,
                             username: username,
                             firstname: firstname,
                             lastname: lastname,
                             age: age,
                             gender: gender,
                             height: height,
                             weight: weight)
    }
}

extension Future where T: Golfer {
    func convertToPublic() -> Future<Golfer.Public> {
        return self.map(to: Golfer.Public.self) { golfer in
            return golfer.convertToPublic()
        }
    }
}

extension Golfer: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \Golfer.username
    static let passwordKey: PasswordKey = \Golfer.password
}

extension Golfer: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminGolfer: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection)
        -> Future<Void> {
            /*
            let settings = ConfigurationManager().load(.environmentVariables)
            let envPassword = settings["VAPORGOLF_ADMIN_PASSWORD"] as? String
            guard let validPassword = envPassword else {
                fatalError("Failed to load password from environment")
            }
             
            let password = try? BCrypt.hash(validPassword)
             */
            let password = try? BCrypt.hash("password")
            guard let hashedPassword = password else {
                fatalError("Failed to create admin user")
            }
            let golfer = Golfer(username: "admin",
                                password: hashedPassword,
                                firstname: "",
                                lastname: "",
                                age: 0,
                                gender: "",
                                height: 0,
                                weight: 0)
            return golfer.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection)
        -> Future<Void> {
            return .done(on: connection)
    }
}
