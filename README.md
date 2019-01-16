<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</p>

# VaporGolf
REST/HTTP API built using Vapor for use by client applications relating to Golf

## Documentation

### Models

#### Golfer
  Represents a person who plays Golf
  
  Properties:
  firstName: String
  lastName: String
  age: Int
  gender: String
  height: Int (inches)
  weight: Int (lbs)
  
  Relationships: Parent of Score
  
#### GolfCourse
  Represents a physical location where Golfers can play Golf
  
  Properties:
  name: String
  streetAddress: String
  city: String
  state: String
  phoneNumber: String
  
  Relationships: Parent of Tee

#### Tee
  Represents a tee box on the golf course where golfers choose to play from
  
  Properties:
  name: String
  
  Relationships: Child of Golf Course
  
#### Hole
  Represents a hole on the golf course where a golfer starts by hitting
  a golf ball from the tee box and ends by hitting a golf ball into a hole
  
  Properties:
  holeNumber: Int
  par: Int
  handicap: Int
  yardage: Int
  
  Relationships: Child of Tee
  
#### Score
  Represents the scoring results of a golfer playing golf at a golf course
  
  Properties: 
  date: Date
  strokesPerHole: [Int]
  puttsPerHole: [Int]
  greensInRegulation: [Bool]
  totalScore: Int
  
  Relationships: Child of Golfer and Tee
  
### Endpoints

#### Golfer Endpoints

#### GolfCourse Endpoints

#### Tee Endpoints

#### Hole Endpoints

#### Score Endpoints

### Docker
  Models are persisted using a PostgreSQL database running inside of a docker container. There are two docker containers 
  running PostgreSQL, one for production and one for testing.

 
