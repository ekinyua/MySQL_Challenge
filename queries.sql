-- Find all projects with a deadline before December 1st, 2024.
SELECT * FROM projects
WHERE deadline < '2024-12-01';

-- List all projects for "Big Retail Inc." ordered by deadline.
SELECT * FROM projects
WHERE client = 'Big Retail Inc.'
ORDER BY deadline;

-- Find the team lead for the "Mobile App for Learning" project.
SELECT team_lead FROM projects
WHERE project_name = 'Mobile App for Learning';


-- Find projects containing "Management" in the name.
SELECT * FROM projects
WHERE project_name LIKE '%Management%';

-- Count the number of projects assigned to David Lee.
SELECT COUNT(*) AS project_count FROM projects
WHERE team_members LIKE '%David Lee%';

-- Find the total number of employees working on each project.
SELECT project_id, project_name, 
       LENGTH(team_members) - LENGTH(REPLACE(team_members, ',', '')) + 1 AS total_employees
FROM projects;

-- Find all clients with projects having a deadline after October 31st, 2024.
SELECT DISTINCT client FROM projects
WHERE deadline > '2024-10-31';

-- List employees who are not currently team leads on any project.
SELECT DISTINCT employee_name FROM employees
WHERE employee_name NOT IN (SELECT team_lead FROM projects);

-- Combine a list of projects with deadlines before December 1st and another list with "Management" in the project name.
SELECT * FROM projects
WHERE deadline < '2024-12-01'
UNION
SELECT * FROM projects
WHERE project_name LIKE '%Management%';

-- Display a message indicating if a project is overdue (deadline passed).
SELECT project_id, project_name,
       CASE
           WHEN deadline < CURDATE() THEN 'Overdue'
           ELSE 'On time'
       END AS status
FROM projects;

-- Views
-- Create a view to simplify retrieving client contact.
CREATE VIEW client_contacts AS
SELECT client, team_lead
FROM projects;

-- Create a view to show only ongoing projects (not yet completed).
CREATE VIEW ongoing_projects AS
SELECT * FROM projects
WHERE deadline >= CURDATE();

-- Create a view to display project information along with assigned team leads.
CREATE VIEW project_info_with_team_leads AS
SELECT project_id, project_name, client, team_lead, deadline
FROM projects;

-- Create a view to show project names and client contact information for projects with a deadline in November 2024.
CREATE VIEW november_2024_projects AS
SELECT project_name, client, team_lead
FROM projects
WHERE deadline BETWEEN '2024-11-01' AND '2024-11-30';

-- Create a view to display the total number of projects assigned to each employee.
CREATE VIEW employee_project_count AS
SELECT team_lead, COUNT(*) AS project_count
FROM projects
GROUP BY team_lead;

-- Create a function to calculate the number of days remaining until a project deadline.
DELIMITER //

CREATE FUNCTION days_until_deadline(proj_id INT)
RETURNS INT
BEGIN
    DECLARE days_left INT;
    SELECT DATEDIFF(deadline, CURDATE()) INTO days_left
    FROM projects
    WHERE project_id = proj_id;
    RETURN days_left;
END //

DELIMITER ;

-- Create a function to calculate the number of days a project is overdue.
DELIMITER //

CREATE FUNCTION days_overdue(proj_id INT)
RETURNS INT
BEGIN
    DECLARE overdue_days INT;
    SELECT DATEDIFF(CURDATE(), deadline) INTO overdue_days
    FROM projects
    WHERE project_id = proj_id AND deadline < CURDATE();
    RETURN overdue_days;
END //

DELIMITER ;

-- Create a stored procedure to add a new client and their first project in one call.
DELIMITER //

CREATE PROCEDURE add_client_and_project(
    IN client_name VARCHAR(255),
    IN project_name VARCHAR(255),
    IN team_lead_name VARCHAR(255),
    IN team_members_list VARCHAR(255),
    IN requirements_text TEXT,
    IN project_deadline DATE
)
BEGIN
    INSERT INTO projects (project_name, client, team_lead, team_members, requirements, deadline)
    VALUES (project_name, client_name, team_lead_name, team_members_list, requirements_text, project_deadline);
END //

DELIMITER ;

-- Create a stored procedure to move completed projects (past deadlines) to an archive table
CREATE TABLE project_archive LIKE projects;

DELIMITER //

CREATE PROCEDURE archive_completed_projects()
BEGIN
    INSERT INTO project_archive SELECT * FROM projects WHERE deadline < CURDATE();
    DELETE FROM projects WHERE deadline < CURDATE();
END //

DELIMITER ;

-- Triggers
-- Create a trigger to log any updates made to project records in a separate table for auditing purposes.
CREATE TABLE project_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSON,
    new_data JSON
);

DELIMITER //

CREATE TRIGGER log_project_updates
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
    INSERT INTO project_audit (project_id, old_data, new_data)
    VALUES (NEW.project_id, JSON_OBJECT('project_name', OLD.project_name, 'client', OLD.client, 'team_lead', OLD.team_lead, 'team_members', OLD.team_members, 'requirements', OLD.requirements, 'deadline', OLD.deadline),
            JSON_OBJECT('project_name', NEW.project_name, 'client', NEW.client, 'team_lead', NEW.team_lead, 'team_members', NEW.team_members, 'requirements', NEW.requirements, 'deadline', NEW.deadline));
END //

DELIMITER ;

-- Create a trigger to ensure a team lead assigned to a project is a valid employee.
DELIMITER //

CREATE TRIGGER validate_team_lead
BEFORE INSERT ON projects
FOR EACH ROW
BEGIN
    DECLARE team_lead_exists INT;
    SELECT COUNT(*) INTO team_lead_exists FROM employees WHERE employee_name = NEW.team_lead;
    IF team_lead_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid team lead.';
    END IF;
END //

DELIMITER ;

-- Additional Views
-- Create a view to display project details along with the total number of team members assigned.
CREATE VIEW project_details_with_team_count AS
SELECT project_id, project_name, client, team_lead, team_members, requirements, deadline,
       LENGTH(team_members) - LENGTH(REPLACE(team_members, ',', '')) + 1 AS total_team_members
FROM projects;

-- Create a view to show overdue projects with the number of days overdue.
CREATE VIEW overdue_projects AS
SELECT project_id, project_name, client, team_lead, team_members, requirements, deadline,
       DATEDIFF(CURDATE(), deadline) AS days_overdue
FROM projects
WHERE deadline < CURDATE();

-- Create a stored procedure to update project team members (remove existing, add new ones).
DELIMITER //

CREATE PROCEDURE update_project_team_members(
    IN proj_id INT,
    IN new_team_members VARCHAR(255)
)
BEGIN
    UPDATE projects
    SET team_members = new_team_members
    WHERE project_id = proj_id;
END //

DELIMITER ;

-- Create a trigger to prevent deleting a project that still has assigned team members.
DELIMITER //

CREATE TRIGGER prevent_project_deletion
BEFORE DELETE ON projects
FOR EACH ROW
BEGIN
    IF OLD.team_members IS NOT NULL AND OLD.team_members <> '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete project with assigned team members.';
    END IF;
END //

DELIMITER ;
