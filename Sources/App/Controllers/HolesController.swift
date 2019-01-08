import Vapor
import Fluent

struct HolesController: RouteCollection {
    
    func boot(router: Router) throws {
        let holesRoutes = router.grouped("api", "holes")
        holesRoutes.post(Hole.self, use: createHandler)
        holesRoutes.delete(Hole.parameter, use: deleteHandler)
        holesRoutes.put(Hole.parameter, use: updateHandler)
        holesRoutes.get(use: getAllHandler)
        holesRoutes.get(Hole.parameter, use: getHandler)
        holesRoutes.get("first", use: getFirstHandler)
        holesRoutes.get("search", use: getSearchHandler)
        holesRoutes.get("sorted", use: getSortedHandler)
        holesRoutes.get(Hole.parameter, "scorecards", use: getScorecardHandler)
    }
    
    func createHandler(_ req: Request, hole: Hole) throws -> Future<Hole> {
        return hole.save(on: req)
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Hole.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Hole> {
        return try flatMap(
            to: Hole.self,
            req.parameters.next(Hole.self),
            req.content.decode(Hole.self)) {
                hole, updatedHole in
                hole.holeNumber = updatedHole.holeNumber
                hole.tee = updatedHole.tee
                hole.par = updatedHole.par
                hole.handicap = updatedHole.handicap
                hole.yardage = updatedHole.yardage
                return hole.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Hole]> {
        return Hole.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Hole> {
        return try req.parameters.next(Hole.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Hole> {
        return Hole.query(on: req)
            .first()
            .map(to: Hole.self) { hole in
                guard let hole = hole else {
                    throw Abort(.notFound)
                }
                return hole
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[Hole]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Hole.query(on: req).group(.or) { or in
            or.filter(\.tee == searchTerm)
            or.filter(\.holeNumberStr == searchTerm)
            or.filter(\.parStr == searchTerm)
            or.filter(\.handicapStr == searchTerm)
            or.filter(\.yardageStr == searchTerm)
        }.all()
    }
    
    func getSortedHandler(_ req: Request) throws -> Future<[Hole]> {
        return Hole.query(on: req).sort(\.par, .ascending).all()
    }
    
    func getScorecardHandler(_ req: Request) throws -> Future<Scorecard> {
        return try req.parameters
            .next(Hole.self)
            .flatMap(to: Scorecard.self) {
                hole in hole.scorecard.get(on: req)
        }
    }
    
}
