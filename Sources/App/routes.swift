import Vapor

public func routes(_ router: Router) throws {

    router.get { req in
        return "Welcome to VaporGolf!"
    }
    
    let golfCoursesController = GolfCoursesController()
    let golfersController = GolfersController()
    let teesController = TeesController()
    let holesController = HolesController()
    let scoresController = ScoresController()
    let scoreImagesController = ScoreImagesController()
    
    try router.register(collection: golfCoursesController)
    try router.register(collection: golfersController)
    try router.register(collection: teesController)
    try router.register(collection: holesController)
    try router.register(collection: scoresController)
    try router.register(collection: scoreImagesController)
    

}
