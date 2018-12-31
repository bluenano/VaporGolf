import Vapor
import FluentSQLite

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

extension Golfer: Model {
    typealias Database = SQLiteDatabase
    typealias ID = Int
    
    public static var idKey: IDKey = \Golfer.id
}

extension Golfer: Migration {}
