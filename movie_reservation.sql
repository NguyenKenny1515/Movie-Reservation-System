DROP DATABASE IF EXISTS MOVIE_RESERVATION;
CREATE DATABASE MOVIE_RESERVATION;
USE MOVIE_RESERVATION;

DROP TABLE IF EXISTS Movies;
CREATE TABLE Movies (
    mID VARCHAR(15) PRIMARY KEY,
    title VARCHAR(80),
    releaseYear INT,
    runTime INT,
    genre TEXT,
    UNIQUE(title, releaseYear)
);

DROP TABLE IF EXISTS Ratings;
CREATE TABLE Ratings (
    mID VARCHAR(15) PRIMARY KEY,
    imdbScore FLOAT,
    numVotes INT,
    FOREIGN KEY(mID) REFERENCES Movies(mID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS People;
CREATE TABLE People (
    pID VARCHAR(15) PRIMARY KEY,
    name TEXT NOT NULL,
    birthYear INT,
    deathYear INT,
    profession TEXT
);

DROP TABLE IF EXISTS Cast;
CREATE TABLE Cast (
    mID VARCHAR(15) NOT NULL,
    pID VARCHAR(15) NOT NULL,
    role TEXT,
    UNIQUE (mID, pID),
    FOREIGN KEY(mID) REFERENCES Movies(mID) ON DELETE CASCADE,
    FOREIGN KEY(pID) REFERENCES People(pID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    username VARCHAR(30) PRIMARY KEY,
    password TEXT NOT NULL CHECK (LENGTH(password) >= 5),
    accountType TEXT NOT NULL
);

DROP TABLE IF EXISTS ShowTimes;
CREATE TABLE ShowTimes (
    sID INT PRIMARY KEY AUTO_INCREMENT,
    mID VARCHAR(15) NOT NULL,
    startTime TIME,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (mID, startTime),
    FOREIGN KEY(mID) REFERENCES Movies(mID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Reservations;
CREATE TABLE Reservations (
    rID INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL,
    sID INT NOT NULL,
    creationTime TIMESTAMP,
    FOREIGN KEY(username) REFERENCES Users(username) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(sID) REFERENCES ShowTimes(sID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Archive;
CREATE TABLE Archive (
    sID INT PRIMARY KEY,
    mID VARCHAR(15) NOT NULL,
    startTime TIME,
    updatedAt TIMESTAMP
);

DROP PROCEDURE IF EXISTS archiveShowTimes;
DELIMITER //
CREATE PROCEDURE archiveShowTimes (IN archiveDate DATE)
BEGIN
	INSERT INTO Archive (SELECT * FROM showTimes WHERE DATE(updatedAt) < archiveDate);
	DELETE FROM showTimes WHERE DATE(updatedAt) < archiveDate;
END;
//
DELIMITER ;

DROP TRIGGER IF EXISTS InsertReservations;
DELIMITER //
CREATE TRIGGER InsertReservations 
BEFORE INSERT ON Reservations
FOR EACH ROW 
BEGIN
	SET NEW.creationTime = now();
END;
//
DELIMITER ;

DROP TRIGGER IF EXISTS FixPassword;
DELIMITER //
CREATE TRIGGER FixPassword 
BEFORE INSERT ON Users
FOR EACH ROW 
BEGIN
    IF LENGTH(NEW.password) < 5 THEN
        SET NEW.password = 'password';
    END IF;
END;
//
DELIMITER ;

SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE 'C:/Users/nguye/Documents/CS 157A/yesSQL/CS157A-Project/movies.csv' 
INTO TABLE Movies 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/nguye/Documents/CS 157A/yesSQL/CS157A-Project/ratings.csv'
INTO TABLE Ratings 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/nguye/Documents/CS 157A/yesSQL/CS157A-Project/people.csv' 
INTO TABLE People 
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/nguye/Documents/CS 157A/yesSQL/CS157A-Project/cast.csv' 
INTO TABLE Cast 
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(mID, pID, role);

LOAD DATA LOCAL INFILE 'C:/Users/nguye/Documents/CS 157A/yesSQL/CS157A-Project/showtimes.csv' 
INTO TABLE ShowTimes 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(mID, startTime);

UPDATE Movies SET 
    mID = TRIM(TRAILING '\r' FROM mID),
    title = TRIM(TRAILING '\r' FROM title),
    releaseYear = TRIM(TRAILING '\r' FROM releaseYear),
    runTime = TRIM(TRAILING '\r' FROM runTime),
    genre = TRIM(TRAILING '\r' FROM genre);

UPDATE Ratings SET 
    mID = TRIM(TRAILING '\r' FROM mID),
    imdbScore = TRIM(TRAILING '\r' FROM imdbScore),
    numVotes = TRIM(TRAILING '\r' FROM numVotes);

UPDATE People SET 
    pID = TRIM(TRAILING '\r' FROM pID),
    name = TRIM(TRAILING '\r' FROM name),
    birthYear = TRIM(TRAILING '\r' FROM birthYear),
    deathYear = TRIM(TRAILING '\r' FROM deathYear),
    profession = TRIM(TRAILING '\r' FROM profession);

UPDATE Cast SET
    mID = TRIM(TRAILING '\r' FROM mID),
    pID = TRIM(TRAILING '\r' FROM pID),
    role = TRIM(TRAILING '\r' FROM role);

UPDATE ShowTimes SET
    mID = TRIM(TRAILING '\r' FROM mID),
    startTime = TRIM(TRAILING '\r' FROM startTime);
