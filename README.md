# VaporGolf
REST/HTTP API built using Vapor for use by client applications relating to golf </br>

## Documentation

### Models

#### Golfer
Represents a person who plays golf </br>

##### Properties 
| id                 | Int?         |
|--------------------|--------------|
| firstName          | String       |
| lastName           | String       | 
| age                | Int          |
| gender             | String       |
| height             | Int (inches) |
| weight             | Int (inches) |


#### GolfCourse
Represents a physical location where golfers can play golf </br>

##### Properties
| id                 | Int?         |
|--------------------|--------------|
| name               | String       |
| streetAddress      | String       |
| city               | String       |
| state              | String       |
| country            | String       |
| phoneNumber        | String       |

#### Tee
Represents a tee box on the golf course where golfers choose to play from </br>

##### Properties
| id                 | Int?         |
|--------------------|--------------|
| name               | String       |

#### Hole
Represents a hole on the golf course where a golfer starts by hitting </br>
a golf ball from the tee box and ends by hitting a golf ball into a hole </br>

##### Properties
| id                 | Int?         |
|--------------------|--------------|
| holeNumber         | Int          |
| par                | Int          | 
| handicap           | Int          |
| yardage            | Int          |

  
#### Score
Represents the scoring results of a golfer playing golf at a golf course </br>

##### Properties

| id                 | Int?         |
|--------------------|--------------|
| date               | Date         |
| strokesPerHole     | [Int]        | 
| puttsPerHole       | [Int]        |
| greensInRegulation | [Bool]       |
| fairwaysHit        | [Bool]       |
| totalScore         | Int          |
| golferID           | Golfer.ID    |
| teeID              | Tee.ID       |

#### ScoreImage
Represents an image of a filled out scorecard from playing golf </br>

##### Properties 
| id                 | Int?         |
|--------------------|--------------|
| imageData          | File?        |
| scoreID            | Score.ID     | 
  
### Endpoints

#### Golfer Endpoints
| Endpoint                 | HTTP Methods | Parameters |   |   |
|--------------------------|--------------|------------|---|---|
| /api/golfers             |              |            |   |   |
| /api/golfers/{golfer_id} |              |            |   |   |
| /api/golfers/first       |              |            |   |   |
| /api/golfers/search      |              |            |   |   |
| /api/golfers/sorted      |              |            |   |   |

#### GolfCourse Endpoints
| Endpoint                          | HTTP Methods | Parameters |   |   |
|-----------------------------------|--------------|------------|---|---|
| /api/golfcourses                  |              |            |   |   |
| /api/golfcourses/{golfcourses_id} |              |            |   |   |
| /api/golfcourses/first            |              |            |   |   |
| /api/golfcourses/search           |              |            |   |   |
| /api/golfcourses/sorted           |              |            |   |   |

#### Tee Endpoints
| Endpoint           | HTTP Methods | Parameters |   |   |
|--------------------|--------------|------------|---|---|
| /api/tees          |              |            |   |   |
| /api/tees/{tee_id} |              |            |   |   |
| /api/tees/first    |              |            |   |   |
| /api/tees/search   |              |            |   |   |
| /api/tees/sorted   |              |            |   |   |

#### Hole Endpoints
| Endpoint             | HTTP Methods | Parameters |   |   |
|----------------------|--------------|------------|---|---|
| /api/holes           |              |            |   |   |
| /api/holes/{hole_id} |              |            |   |   |
| /api/holes/first     |              |            |   |   |
| /api/holes/search    |              |            |   |   |
| /api/holes/sorted    |              |            |   |   |

#### Score Endpoints
| Endpoint               | HTTP Methods | Parameters |   |   |
|------------------------|--------------|------------|---|---|
| /api/scores            |              |            |   |   |
| /api/scores/{score_id} |              |            |   |   |
| /api/scores/first      |              |            |   |   |
| /api/scores/search     |              |            |   |   |
| /api/scores/sorted     |              |            |   |   |


#### ScoreImage Endpoints
| Endpoint                         | HTTP Methods | Parameters |   |   |
|----------------------------------|--------------|------------|---|---|
| /api/scoreimages                 |              |            |   |   |
| /api/scoreimages/{scoreimage_id} |              |            |   |   |
| /api/scoreimages/first           |              |            |   |   |


### Docker
Models are persisted using a PostgreSQL database running inside of a docker container </br>
There are two docker containers running PostgreSQL, one for production and one for testing </br>

 
