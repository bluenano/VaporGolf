import Vapor
import FluentPostgreSQL

final class Golfer: Codable {
    
    var id: Int?
    var firstName: String
    var lastName: String
    var age: Int
    var gender: String
    var weight: Int
    
    init(firstName: String, lastName:String, age: Int,
         gender: String, weight: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.gender = gender
        self.weight = weight
    }
}

extension Golfer: PostgreSQLModel {}
extension Golfer: Migration {}
extension Golfer: Content {}
extension Golfer: Parameter {}

extension Golfer {
    var scores: Children<Golfer, Score> {
        return children(\.golferID)
    }
}

extension Golfer {
    var ageStr: String {
        return String(age)
    }
    
    var weightStr: String {
        return String(weight)
    }
}


