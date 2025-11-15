-- =============================================
-- EXERCISE 2.3.1: MOVIE DATABASE SCHEMA
-- Created by: [Your Name]
-- Date: [Today's Date]
-- =============================================

-- Product Table
CREATE TABLE Product
(
  maker VARCHAR(50),
  model INT PRIMARY KEY,
  type VARCHAR(10) CHECK (type IN ('PC', 'Laptop', 'Printer'))
);

-- PC Table
CREATE TABLE PC
(
  model INT PRIMARY KEY,
  speed DECIMAL(4,2),
  ram INT,
  hd INT,
  price DECIMAL(10,2),
  FOREIGN KEY (model) REFERENCES Product(model)
);

-- Laptop Table
CREATE TABLE Laptop
(
  model INT PRIMARY KEY,
  speed DECIMAL(4,2),
  ram INT,
  hd INT,
  screen DECIMAL(3,1),
  price DECIMAL(10,2),
  FOREIGN KEY (model) REFERENCES Product(model)
);

-- Printer Table
CREATE TABLE Printer
(
  model INT PRIMARY KEY,
  color BOOLEAN,
  type VARCHAR(10) CHECK (type IN ('laser', 'ink-jet')),
  price DECIMAL(10,2),
  FOREIGN KEY (model) REFERENCES Product(model)
);

-- Exercise E: Remove color attribute from Printer
ALTER TABLE Printer DROP COLUMN color;

-- Exercise F: Add optical disk to Laptop
ALTER TABLE Laptop ADD COLUMN od VARCHAR
(10) DEFAULT 'none';

-- =============================================
-- SAMPLE DATA (Optional)
-- =============================================
/*
INSERT INTO Product VALUES ('Dell', 1001, 'PC');
INSERT INTO PC VALUES (1001, 3.2, 8, 500, 799.99);
*/