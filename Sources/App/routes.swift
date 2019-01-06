import Vapor

public func routes(_ router: Router) throws {

    router.get { req in
        return "Welcome to VaporGolf!"
    }
    
    let golfCoursesController = GolfCoursesController()
    let golfersController = GolfersController()
    let scorecardsController = ScorecardsController()
    let scoresController = ScoresController()
    let holesController = HolesController()
    
    try router.register(collection: golfCoursesController)
    try router.register(collection: golfersController)
    try router.register(collection: scorecardsController)
    try router.register(collection: scoresController)
    try router.register(collection: holesController)
    

}
