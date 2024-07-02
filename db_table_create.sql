CREATE DATABASE SoftwareCompany;
USE SoftwareCompany;

-- Employees Table
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeName VARCHAR(255) NOT NULL
);

-- Clients Table
CREATE TABLE Clients (
    ClientID INT AUTO_INCREMENT PRIMARY KEY,
    ClientName VARCHAR(255) NOT NULL,
    ContactName VARCHAR(255) NOT NULL,
    ContactEmail VARCHAR(255) NOT NULL
);

-- Projects Table
CREATE TABLE Projects (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(255) NOT NULL,
    Requirements TEXT,
    Deadline DATE,
    ClientID INT,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);

-- Team Members Table
CREATE TABLE Team_Members (
    ProjectID INT,
    EmployeeID INT,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    PRIMARY KEY (ProjectID, EmployeeID)
);

-- Project Team Table
CREATE TABLE Project_Team (
    ProjectID INT,
    EmployeeID INT,
    IsTeamLead BOOLEAN,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    PRIMARY KEY (ProjectID, EmployeeID)
);

-- Archive Table for Completed Projects
CREATE TABLE Archived_Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(255),
    Requirements TEXT,
    Deadline DATE,
    ClientID INT
);