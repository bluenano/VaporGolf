import Vapor
import Fluent

struct GolfersController: RouteCollection {
    
    func boot(router: Router) throws {
        let golfersRoutes = router.grouped("api", "golfers")
        golfersRoutes.post(Golfer.self, use: createHandler)
        golfersRoutes.delete(use: deleteHandler)
        golfersRoutes.put(use: updateHandler)
        golfersRoutes.get(use: getAllHandler)
        golfersRoutes.get(use: getHandler)
        golfersRoutes.get("first", use: getFirstHandler)
        golfersRoutes.get("search", use: getSearchHandler)
        golfersRoutes.get("sorted", use: getSortedHandler)
        golfersRoutes.get(Golfer.parameter, "scores", use: getScoresHandler)
    }
    
    func createHandler(_ req: Request, golfer: Golfer) throws -> Future<Golfer> {
            return golfer.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Golfer.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
        
    }
    
    func updateHandler(_ req: Request) throws -> Future<Golfer> {
        return try flatMap(
            to: Golfer.self,
            req.parameters.next(Golfer.self),
            req.content.decode(Golfer.self)) {
                golfer, updatedGolfer in
                golfer.firstName = updatedGolfer.firstName
                golfer.lastName = updatedGolfer.lastName
                golfer.age = updatedGolfer.age
                golfer.weight = updatedGolfer.weight
                golfer.gender = updatedGolfer.gender
                return golfer.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Golfer]> {
        return Golfer.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Golfer> {
        return try req.parameters.next(Golfer.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Golfer> {
        return Golfer.query(on: req)
            .first()
            .map(to: Golfer.self) { golfer in
                guard let golfer = golfer else {
                    throw Abort(.notFound)
                }
                return golfer
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[Golfer]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Golfer.query(on: req).group(.or) { or in
            or.filter(\.firstName == searchTerm)
            or.filter(\.lastName == searchTerm)
            or.filter(\.ageStr == searchTerm)
            or.filter(\.weightStr == searchTerm)
            or.filter(\.gender == searchTerm)
        }.all()
    }

    func getSortedHandler(_ req: Request) throws -> Future<[Golfer]> {
        return Golfer.query(on: req).sort(\.lastName, .ascending).all()
    }
    
    func getScoresHandler(_ req: Request) throws -> Future<[Score]> {
        return try req.parameters
            .next(Golfer.self)
            .flatMap(to: [Score].self) { golfer in
                try golfer.scores.query(on: req).all()
        }
    }
 }
