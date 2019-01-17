import Vapor
import FluentPostgreSQL

struct TeesController: RouteCollection {
    
    func boot(router: Router) throws {
        let teesRoutes = router.grouped("api", "tees")
        teesRoutes.post(Tee.self, use: createHandler)
        teesRoutes.delete(Tee.parameter, use: deleteHandler)
        teesRoutes.put(Tee.parameter, use: updateHandler)
        teesRoutes.get(use: getAllHandler)
        teesRoutes.get(Tee.parameter, use: getHandler)
        teesRoutes.get("first", use: getFirstHandler)
        teesRoutes.get("search", use: getSearchHandler)
        teesRoutes.get("sorted", use: getSortedHandler)
        teesRoutes.get(Tee.parameter, "golfcourse", use: getGolfCourseHandler)
    }
    
    func createHandler(_ req: Request, tee: Tee) throws -> Future<Tee> {
        return tee.save(on: req)
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Tee.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Tee> {
        return try flatMap(
            to: Tee.self,
            req.parameters.next(Tee.self),
            req.content.decode(Tee.self)) { tee, updatedTee in
                tee.name = updatedTee.name
                tee.golfCourseID = updatedTee.golfCourseID
                return tee.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Tee]> {
        return Tee.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Tee> {
        return try req.parameters.next(Tee.self)
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Tee> {
        return Tee.query(on: req)
            .first()
            .map(to: Tee.self) { tee in
                guard let tee = tee else {
                    throw Abort(.notFound)
                }
                return tee
        }
    }
    
    func getSearchHandler(_ req: Request) throws -> Future<[Tee]> {
        guard let searchTerm =
            req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        return Tee.query(on: req).group(.or) { or in
            or.filter(\.name == searchTerm)
        }.all()
    }
    
    func getSortedHandler(_ req: Request) throws -> Future<[Tee]> {
        return Tee.query(on: req).sort(\.name, .ascending).all()

    }
    
    func getGolfCourseHandler(_ req: Request) throws -> Future<GolfCourse> {
        return try req.parameters
            .next(Tee.self)
            .flatMap(to: GolfCourse.self) {
                tee in tee.golfCourse.get(on: req)
        }
    }
}
