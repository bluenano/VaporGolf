import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }gi
    
    // Configure golf courses controller
    let golfCoursesController = GolfCoursesController()
    try router.register(collection: golfCoursesController)

}
