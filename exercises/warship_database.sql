-- =============================================
-- EXERCISE 2.3.2: WARSHIP DATABASE SCHEMA
-- Created by: [Your Name]
-- Date: [Today's Date]
-- =============================================

-- Classes Table
CREATE TABLE Classes
(
  class VARCHAR(50) PRIMARY KEY,
  type CHAR(2) CHECK (type IN ('bb', 'bc')),
  country VARCHAR(50),
  numGuns INT,
  bore DECIMAL(4,2),
  displacement INT
);

-- Ships Table
CREATE TABLE Ships
(
  name VARCHAR(50) PRIMARY KEY,
  class VARCHAR(50),
  launched INT,
  FOREIGN KEY (class) REFERENCES Classes(class)
);

-- Battles Table
CREATE TABLE Battles
(
  name VARCHAR(50) PRIMARY KEY,
  date DATE
);

-- Outcomes Table
CREATE TABLE Outcomes
(
  ship VARCHAR(50),
  battle VARCHAR(50),
  result VARCHAR(10) CHECK (result IN ('sunk', 'damaged', 'ok')),
  PRIMARY KEY (ship, battle),
  FOREIGN KEY (ship) REFERENCES Ships(name),
  FOREIGN KEY (battle) REFERENCES Battles(name)
);

-- Exercise E: Remove bore from Classes
ALTER TABLE Classes DROP COLUMN bore;

-- Exercise F: Add shipyard to Ships
ALTER TABLE Ships ADD COLUMN yard VARCHAR
(100);

-- =============================================
-- SAMPLE DATA (Optional)
-- =============================================
/*
INSERT INTO Classes VALUES ('Iowa', 'bb', 'USA', 9, 16.0, 45000);
INSERT INTO Ships VALUES ('USS Missouri', 'Iowa', 1944);
*/