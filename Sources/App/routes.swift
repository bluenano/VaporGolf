import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    /*
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    */
    router.post("api", "golfcourse") { req -> Future<GolfCourse> in
        return try req.content.decode(GolfCourse.self)
            .flatMap(to: GolfCourse.self) { golfCourse in
                return golfCourse.save(on: req)
        }
    }
}
