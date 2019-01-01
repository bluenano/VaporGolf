import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    // Example of configuring a controller
    /*
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    */
    
    // define HTTP POST request to create a golf course
    router.post("api", "golfcourses") { req -> Future<GolfCourse> in
        return try req.content.decode(GolfCourse.self)
            .flatMap(to: GolfCourse.self) { golfCourse in
                return golfCourse.save(on: req)
        }
    }
    
    // define HTTP GET request to access all golf courses
    router.get("api", "golfcourses") { req -> Future<[GolfCourse]> in
        return GolfCourse.query(on: req).all()
    }
    
    // define HTTP GET request to access a golf course by id
    router.get("api", "golfcourses", GolfCourse.parameter) {
        req -> Future<GolfCourse> in
        return try req.parameters.next(GolfCourse.self)
    }
    
    // define HTTP GET request to search for golf courses
    // Xcode does not like this code
    /*
    router.get("api", "golfcourses", "search") {
        req -> Future<[GolfCourse]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return GolfCourse.query(on: req)
            .filter(\.name == searchTerm)
            .all()
    }
    */
    
    // define HTTP GET request to return the first golf course
    router.get("api", "golfcourses", "first") {
        req -> Future<GolfCourse> in
        return GolfCourse.query(on: req)
            .first()
            .map(to: GolfCourse.self) { golfCourse in
                guard let golfCourse = golfCourse else {
                    throw Abort(.notFound)
                }
                return golfCourse
        }
    }
    
    // define HTTP GET request to return sorted results
    router.get("api", "golfcourses", "sorted") {
        req -> Future<[GolfCourse]> in
        return GolfCourse.query(on:req)
        .sort(\.name, .ascending)
        .all()
    }
    
    // define HTTP PUT request to update a golf course
    router.put("api", "golfcourses", GolfCourse.parameter) {
        req -> Future<GolfCourse> in
        return try flatMap(to: GolfCourse.self,
                           req.parameters.next(GolfCourse.self),
                           req.content.decode(GolfCourse.self)) {
            golfCourse, updatedGolfCourse in
            golfCourse.name = updatedGolfCourse.name
            golfCourse.address = updatedGolfCourse.address
            return golfCourse.save(on: req)
        }
    }
    
    // define HTTP DELETE request to delete a golf course
    router.delete("api", "golfcourses", GolfCourse.parameter) {
        req -> Future<HTTPStatus> in
        return try req.parameters.next(GolfCourse.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

}
