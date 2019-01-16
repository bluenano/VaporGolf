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
REST/HTTP API built using Vapor for use by client applications relating to golf </br>
## Documentation

### Models

#### Golfer
Represents a person who plays golf </br>
</br>
**Properties:** </br>
firstName: String </br>
lastName: String </br>
age: Int </br>
gender: String </br>
height: Int (inches) </br>
weight: Int (lbs) </br>
</br>
**Relationships:** </br>
Parent of Score </br>

#### GolfCourse
Represents a physical location where golfers can play golf </br>
</br>
**Properties:** </br>
name: String </br>
streetAddress: String </br>
city: String </br>
state: String </br>
phoneNumber: String </br>
</br>
**Relationships:** </br>
Parent of Tee </br>

#### Tee
Represents a tee box on the golf course where golfers choose to play from </br>
</br>
**Properties:** </br>
name: String </br>
</br>  
**Relationships:** </br>
Child of Golf Course </br>

#### Hole
Represents a hole on the golf course where a golfer starts by hitting </br>
a golf ball from the tee box and ends by hitting a golf ball into a hole </br>
</br>
**Properties:** </br>
holeNumber: Int </br>
par: Int </br>
 handicap: Int </br>
yardage: Int </br>
</br>
**Relationships:** </br>
Child of Tee </br>
  
#### Score
Represents the scoring results of a golfer playing golf at a golf course </br>
</br>
**Properties:** </br>
date: Date </br>
strokesPerHole: [Int] </br>
puttsPerHole: [Int] </br>
greensInRegulation: [Bool] </br>
totalScore: Int </br>
</br>
**Relationships:** </br>
Child of Golfer and Tee </br>
  
### Endpoints

#### Golfer Endpoints

#### GolfCourse Endpoints

#### Tee Endpoints

#### Hole Endpoints

#### Score Endpoints

### Docker
Models are persisted using a PostgreSQL database running inside of a docker container </br>
There are two docker containers running PostgreSQL, one for production and one for testing </br>

 
