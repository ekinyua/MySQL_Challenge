-- Insert Clients
INSERT INTO Clients (ClientID, ClientName, ContactName, ContactEmail) VALUES
(1, 'Big Retail Inc.', 'Peter Parker', '[email address]'),
(2, 'EduTech Solutions', 'Walter White', '[email address]'),
(3, 'Trendsetters Inc.', 'Sandra Bullock', '[email address]'),
(4, 'Gearhead Supply Co.', 'Daniel Craig', '[email address]'),
(5, 'Fine Dine Group', 'Olivia Rodriguez', '[email address]'),
(6, 'Green Thumb Gardens', 'Mark Robinson', '[email address]'),
(7, 'Busy Bees Daycare', 'Emily Blunt', '[email address]'),
(8, 'Acme Pharmaceuticals', 'David Kim', '[email address]'),
(9, 'Knowledge Stream Inc.', 'Matthew McConaughey', '[email address]'),
(10, 'Software Craft LLC', 'Jennifer Lopez', '[email address]');

-- Insert Employees
INSERT INTO Employees (EmployeeID, EmployeeName) VALUES
(1, 'David Lee'),
(2, 'Alice Brown'),
(3, 'Jane Doe'),
(4, 'Michael Young'),
(5, 'Emily Chen'),
(6, 'William Green'),
(7, 'Sarah Jones');

-- Insert Projects
INSERT INTO Projects (ProjectID, ProjectName, Requirements, Deadline, ClientID) VALUES
(1, 'E-commerce Platform', 'Extensive documentation', '2024-12-01', 1),
(2, 'Mobile App for Learning', 'Gamified learning modules', '2024-08-15', 2),
(3, 'Social Media Management Tool', 'User-friendly interface with analytics', '2024-10-31', 3),
(4, 'Inventory Management System', 'Barcode integration and real-time stock tracking', '2024-11-01', 4),
(5, 'Restaurant Reservation System', 'Online booking with table management', '2024-09-01', 5),
(6, 'Content Management System (CMS)', 'Drag-and-drop interface for easy content updates', '2024-12-15', 6),
(7, 'Customer Relationship Management (CRM)', 'Secure parent portal and communication tools', '2024-10-01', 7),
(8, 'Data Analytics Dashboard', 'Real-time visualization of key performance indicators (KPIs)', '2024-11-30', 8),
(9, 'E-learning Platform Development', 'Interactive course creation and delivery tools', '2024-09-15', 9),
(10, 'Bug Tracking and Issue Management System', 'Prioritization and collaboration features for bug reporting', '2024-12-31', 10);

-- Insert Team Members
INSERT INTO Team_Members (ProjectID, EmployeeID) VALUES
(1, 1), (1, 2), (2, 1), (2, 3), (3, 2), (3, 3), (4, 1), (4, 3), (5, 2), (5, 5), (6, 1), (6, 3), (7, 2), (7, 5), (8, 1), (8, 3), (9, 2), (9, 3), (10, 1), (10, 5);

-- Insert Project Team
INSERT INTO Project_Team (ProjectID, EmployeeID, IsTeamLead) VALUES
(1, 2, TRUE), (1, 1, FALSE), (1, 3, FALSE),
(2, 1, TRUE), (2, 3, FALSE), (2, 4, FALSE),
(3, 2, TRUE), (3, 3, FALSE), (3, 6, FALSE),
(4, 1, TRUE), (4, 3, FALSE), (4, 5, FALSE),
(5, 2, TRUE), (5, 6, FALSE), (5, 7, FALSE),
(6, 1, TRUE), (6, 3, FALSE), (6, 4, FALSE),
(7, 2, TRUE), (7, 6, FALSE), (7, 7, FALSE),
(8, 1, TRUE), (8, 4, FALSE), (8, 5, FALSE),
(9, 2, TRUE), (9, 3, FALSE), (9, 6, FALSE),
(10, 1, TRUE), (10, 4, FALSE), (10, 7, FALSE);

UPDATE Projects p
JOIN Project_Team pt ON p.ProjectID = pt.ProjectID
JOIN Employees e ON pt.EmployeeID = e.EmployeeID
SET p.TeamLead = e.EmployeeName
WHERE pt.IsTeamLead = TRUE;

-- Step 2: Populate the Clients column
UPDATE Projects p
JOIN Clients c ON p.ClientID = c.ClientID
SET p.Clients = c.ClientName;

-- Step 2: Populate the TeamMembers column
UPDATE Projects p
SET p.TeamMembers = (
    SELECT GROUP_CONCAT(e.EmployeeName SEPARATOR ', ')
    FROM Project_Team pt
    JOIN Employees e ON pt.EmployeeID = e.EmployeeID
    WHERE pt.ProjectID = p.ProjectID AND pt.IsTeamLead = FALSE
)