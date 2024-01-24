-- 1 Create function to calculate the number of students who get 
-- (grade less than 80) in a certain exam 
-- (course id will be sent as a parameter)
DELIMITER $
CREATE OR REPLACE FUNCTION students_grades_less_80(p_course_id INTEGER(2))
RETURNS INTEGER(5)
BEGIN
    DECLARE  v_count INTEGER(5);
    SET v_count = (
        SELECT COUNT(*) FROM students_courses 
        WHERE grade < 80 AND course_id = p_course_id
    );
    RETURN v_count;
END$
DELIMITER ;
-- 2 Create stored procedure to display the names of the absence students of a
-- certain courses.(Absent means has no grades)

DELIMITER $
CREATE OR REPLACE PROCEDURE absent_students(p_course_id INTEGER(2))
BEGIN
    SELECT CONCAT_WS(" ",s.first_name, s.last_name) full_name FROM
    students s RIGHT JOIN students_courses sc 
    ON sc.student_id = s.student_id
    WHERE sc.course_id = p_course_id AND sc.grade IS NULL;
END$
DELIMITER ;

/*
CALL absent_students(1);
+---------------+
| full_name     |
+---------------+
| Ahmed Ibrahim |
| Ahmed  Ossama |
+---------------+
*/

-- 3 Create stored procedure to calculate the average grades for certain course.
DELIMITER $
CREATE OR REPLACE PROCEDURE average_course(p_course_id INTEGER(2))
BEGIN
    SELECT AVG(sc.grade) FROM
    students_courses sc 
    WHERE sc.course_id = p_course_id;
END$
DELIMITER ;

/*
CALL average_course(3);
+---------------+
| AVG(sc.grade) |
+---------------+
|       85.0000 |
+---------------+
*/

/* 4 create trigger to keep track the changes(updates) of the grades in the studnets_courses table
 ( create changes table with the following fields:
id int  primary key , 
user varchar(30),
action varchar(40), 
old_grade int, 
new_grade int, 
change_date date).

Test the trigger by updating grade int the “Students_courses” table

Confirm that the row is added in the” change_table”

*/

CREATE TABLE `changes` (
    id INTEGER  PRIMARY KEY , 
    user VARCHAR(30),
    change_action VARCHAR(40), 
    old_grade INTEGER, 
    new_grade INTEGER, 
    change_date DATE
);

CREATE TRIGGER change_trig
AFTER UPDATE
ON `students_courses`
FOR EACH row
INSERT INTO `changes` 
(id, user, change_action, old_grade, new_grade, change_date)
VALUES (OLD.course_id, CURRENT_USER(),"Update", OLD.grade, NEW.grade, CURRENT_DATE())
;

UPDATE students_courses
SET grade = 60
WHERE student_id = 1;

SELECT id, user, change_action, old_grade, new_grade 
FROM changes;
/*
+----+----------------+---------------+-----------+-----------+
| id | user           | change_action | old_grade | new_grade |
+----+----------------+---------------+-----------+-----------+
|  1 | root@localhost | Update        |        80 |        60 |
|  2 | root@localhost | Update        |        90 |        60 |
|  3 | root@localhost | Update        |       100 |        60 |
|  4 | root@localhost | Update        |        60 |        60 |
+----+----------------+---------------+-----------+-----------+
*/
SELECT * from students_courses;
/*
+------------+-----------+-------+------------+
| student_id | course_id | grade | reg_date   |
+------------+-----------+-------+------------+
|          1 |         1 |    60 | 2024-01-23 |
|          1 |         2 |    60 | 2024-01-23 |
|          1 |         3 |    60 | 2024-01-23 |
|          1 |         4 |    60 | NULL       |
|          2 |         1 |  NULL | NULL       |
|          2 |         2 |    99 | 2024-01-23 |
|          2 |         3 |    80 | 2024-01-23 |
|          2 |         4 |    75 | NULL       |
|          3 |         1 |  NULL | NULL       |
|          3 |         2 |  NULL | NULL       |
|          3 |         3 |    75 | NULL       |
|          3 |         4 |    70 | 2024-01-23 |
+------------+-----------+-------+------------+
*/

-- 5 Create event to delete the changes tables every 5 minute
DELIMITER $
CREATE EVENT delete_changes
ON SCHEDULE EVERY '5' MINUTE
DO
BEGIN
    DELETE FROM changes;
END$
DELIMITER ;

-- 6 Create a user with your name and give him the privilege to access the grades database
CREATE USER 'Ahmed'@'localhost' IDENTIFIED BY 'myPassword';

GRANT ALL ON grades.* TO 'Ahmed'@'localhost';

-- 7 Connect to mysql using the user you created and try to insert one record in the courses table.
/opt/lampp/bin/mysql -u Ahmed -p
: 
-- 8 Change your password.
SET PASSWORD = password('My New Pass');

-- 9 Show your privileges.
SHOW GRANTS FOR Ahmed@localhost;
/*
+--------------------------------------------------------------------------------------------------------------+
| Grants for Ahmed@localhost                                                                                   |
+--------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `Ahmed`@`localhost` IDENTIFIED BY PASSWORD '*1FDDD756CAD7C6096FE7FA6F7B8195A966E4FF9B' |
| GRANT ALL PRIVILEGES ON `grades`.* TO `Ahmed`@`localhost`                                                    |
+--------------------------------------------------------------------------------------------------------------+
*/
