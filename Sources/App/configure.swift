import FluentMySQL
import FluentSQLite
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()

    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                             username: "vaporgolf",
                                             password: "password",
                                             database: "vaporgolf")
    let mysqlDatabase = MySQLDatabase(config: mysqlConfig)
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vaporgolf"
    let password: String = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseName: String
    var databasePort: Int
    let postgresConfig: PostgreSQLDatabaseConfig
    
    if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5433
    } else {
        databasePort = 5433
    }
    
    if (env == .testing) {
        databaseName = "vapor-test"
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vaporgolf"
        databasePort = 5432
    }


    postgresConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                              port: databasePort,
                                              username: username,
                                              database: databaseName,
                                              password: password)
    let postgresDatabase = PostgreSQLDatabase(config: postgresConfig)
    
    databases.add(database: sqlite, as: .sqlite)
    databases.add(database: mysqlDatabase, as: .mysql)
    databases.add(database: postgresDatabase, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: GolfCourse.self, database: .psql)
    migrations.add(model: Golfer.self, database: .psql)
    migrations.add(model: Scorecard.self, database: .psql)
    migrations.add(model: Hole.self, database: .psql)
    migrations.add(model: Score.self, database: .psql)
    services.register(migrations)
    
    // add Fluent commands
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

}
