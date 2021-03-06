/*
	SQL
		- Structured Query Language. Programming language.
	Data types:
		- CHAR, VARCHAR, INT, FLOAT, DOUBLE, TEXT, BIT, BOOL, ENUM, DATE, TIME, YEAR etc.
		- Constraints: NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT, CREATE INDEX 
	Operators:
		- Arithmetic	: +, -, *, /, %
		- Comparision	: =, <>, >, <, >=, <=
		- Logical		: AND, OR, NOT, LIKE, EXISTS, IN, BETWEEN, ALL, ANY
	Language:
		Commands:
			- Data definition	 : CREATE, ALTER, DROP, TRUNCATE
			- Data Manipulation	 : INSERT, UPDATE, DELETE
			- Data Query 		 ; SELECT
			- Data Control		 : GRANT, REVOKE
			- Transaction Control: COMMIT, ROLLBACK, SAVEPOINT
		Clases:
			- WHERE, WITH, AS
			- ORDER BY (ASC/DESC), GROUP BY (HAVING)
		Aggregation:
			- SUM, COUNT, DISTINCT
		Join:
			- JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN, CROSS JOIN

	MISC:
		1. IF(LOGICAL VALUE, Val1, Val2) -> mysql has.
			-- UPDATE Salary SET sex=IF(sex="m", "f", "m");

	Advantages 
		- Portability, Standardization, Abstraction.
*/


############################## COMMANDS SYNTAX #################################

1. SELECT
	-- SELECT column_name1 FROM table_name;
2. CREATE TABLE
	-- CREATE TABLE Employee_details(  
	-- 							      Emp_Id NUMBER(4) NOT NULL,  
	-- 							      First_name VARCHAR(30),  
	-- 							      Last_name VARCHAR(30),  
	-- 							      Salary Money,  
	-- 							      City VARCHAR(30),  
	-- 							      PRIMARY KEY (Emp_Id)  
	-- 							);
3. ALTER TABLE
	-- ALTER TABLE table_name ADD column_name DATATYPE(SIZE); 
	-- ALTER TABLE table_name MODIFY column_name DATATYPE(SIZE);
	-- ALTER TABLE table_name DROP COLUMN column_name;
	-- ALTER TABLE table_name RENAME TO new_table_name;
	-- ALTER TABLE table_name RENAME COLUMN column_name TO new_column_name;    -> oracle. not working in mysql
		-- / ALTER TABLE table_name CHANGE column_name new_column_name (datatype); ->mysql
4. DROP TABLE
	-- DROP TABLE table_name;
5. TRUNCATE
	-- TRUNCATE TABLE table_name;
6. INSERT INTO
	-- INSERT INTO Employee_details ( Emp_ID, First_name, Last_name, Salary, City)  
	-- 						VALUES  (101, Amit, Gupta, 50000, Mumbai), (101,  John, Aggarwal, 45000, Calcutta), (101, Sidhu, Arora, 55000, Mumbai);
7. UPDATE
	-- UPDATE Employee_details SET Salary = 100000, contact = 8919937623 WHERE Emp_ID = 10; 
8. DELETE
	-- DELETE FROM Employee_details WHERE First_Name = 'Sumith';  
9. ORDER BY 
	-- SELECT * FROM CUSTOMERS ORDER BY NAME DESC;  
10. GROUP BY 
	-- SELECT NAME, SUM (SALARY) FROM Employee GROUP BY NAME;  
	-- SELECT SUBJECT, YEAR, Count (*) FROM Student Group BY SUBJECT, YEAR;  
	-- SELECT NAME, SUM(SALARY) FROM Employee GROUP BY NAME HAVING SUM(SALARY)>23000;  

11. CROSS JOIN (CARTESIAN JOIN) 
	-- SELECT * FROM table1, table2;		-> default join if nothing specified is cross join.
	-- SELECT * FROM table1 CROSS JOIN table2;
12. JOIN (INNER JOIN)
	-- SELECT column FROM table1 t1, table2 t2 WHERE t1.id=t2.c_id;
	-- SELECT column FROM table1 t1 JOIN table2 t2 on t1.id=t2.c_id;
13. LEFT JOIN
	-- SELECT col1, col2 FROM table1 LEFT JOIN table2 on table1.id=table2.someID;
14. RIGHT JOIN
	-- SELECT col1, col2 FROM table1 RIGHT JOIN table2 on table1.id=table2.someID;
14. FULL OUTER JOIN
	-- SELECT col1, col2 FROM table1 FULL OUTER JOIN table2 on table1.id=table2.someID;
		-- (NOT provided in many DB management softwares.) Work around below.
	-- SELECT * FROM table1 LEFT JOIN table2 ON table1.id = table2.id
	--		UNION
	-- SELECT * FROM table1 RIGHT JOIN table2 ON table1.id = table2.id;


############################## POPULAR EXAMPLES #################################

1. Second Highest Salary

--
SELECT DISTINCT  Salary "SecondHighestSalary" FROM Employee 
ORDER BY Salary DESC
LIMIT 1 OFFSET 1 
--
SELECT DISTINCT Salary FROM Employee E 
WHERE (SELECT COUNT(*) FROM Employee WHERE Salary>E.Salary)=1 --  if we need to get the persons ID, will COUNT(*) work correctly ? COUNT(DISTINCT Salary) maybe ? wowooo
--
SELECT MAX(Salary) "SecondHighestSalary" FROM Employee 
WHERE Salary NOT IN (Select MAX(Salary) FROM Employee);
---------------------------------------------------------------------------------

2. Nth Highest Salary

-- 
SELECT DISTINCT Salary FROM Employee
ORDER BY Salary DESC LIMIT 1 OFFSET N-1
--
SELECT DISTINCT Salary FROM Employee E
      WHERE (SELECT COUNT(*) FROM  (SELECT DISTINCT Salary FROM Employee) E2 
             WHERE E.Salary<E2.Salary)=N-1
---------------------------------------------------------------------------------

3. Department Highest Salary

--
SELECT D.Name "Department", E.Name "Employee", E.Salary 
FROM Employee E JOIN Department D on E.DepartmentId = D.Id
WHERE E.Salary=(SELECT MAX(Salary) FROM Employee WHERE DepartmentId=D.Id);
--
SELECT D.Name AS Department ,E.Name AS Employee ,E.Salary 
FROM Employee E, Department D 
WHERE E.DepartmentId = D.id  AND (DepartmentId,Salary) in 
  		(SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)
---------------------------------------------------------------------------------

4. Department Top Three Salaries

--
SELECT D.Name, E.Name, E.Salary FROM Employee E JOIN Department D on E.DepartmentId=D.Id
WHERE 
	(SELECT COUNT(DISTINCT Salary) FROM Employee 
	WHERE DepartmentId=E.DepartmentId AND E.Salary<Salary) < 3;
---------------------------------------------------------------------------------

5. Employees Earning More Than Their Managers

--
SELECT Name "Employee" FROM Employee E
WHERE E.Salary>(SELECT Salary FROM Employee WHERE Id=E.ManagerId);
--
SELECT E1.Name "Employee" FROM Employee E1, Employee E2 
WHERE E1.ManagerId = E2.Id AND E1.Salary > E2.Salary;
---------------------------------------------------------------------------------

6. Delete Duplicate Emails (Retaining least Id one)

--
DELETE FROM Person P1 WHERE EXISTS
(SELECT * FROM Person P2 WHERE P2.Id<P1.ID AND P2.Email=P1.Email);
--
DELETE FROM Person WHERE Id NOT IN(
        SELECT MIN(Id) FROM Person GROUP BY Email
);
---------------------------------------------------------------------------------

7. FIND ALL DATES IDs WITH HIGHER TEMPERATURE COMPARED TO ITS PREVIOUS DATES

-- 
SELECT id FROM Weather W WHERE EXISTS
(SELECT * FROM Weather WHERE TO_DAYS(recordDate)=TO_DAYS(W.recordDate)-1 AND Temperature<W.Temperature);
-- 
SELECT w1.id Id FROM Weather w1 JOIN Weather w2 ON TO_DAYS(w1.recordDate)=TO_DAYS(w2.recordDate)+1 
AND w1.Temperature>w2.Temperature;
---------------------------------------------------------------------------------

8. All People Report to the Given Manager (Max 3 levels)

-- 
SELECT E1.employee_id
FROM Employees E1 JOIN Employees E2 JOIN Employees E3
ON E1.manager_id=E2.employee_id AND E2.manager_id=E3.employee_id
WHERE 
    E1.employee_id!=1
    AND(
        E1.manager_id = 1 OR
        E2.manager_id = 1 OR
        E3.manager_id = 1);
---------------------------------------------------------------------------------

9. NUMBERS THAT APPEAR AT LEAST THREE TIMEs CONSECUTIVELY. Columns(ID, Num)

--
SELECT DISTINCT L1.Num "ConsecutiveNums" FROM Logs L1, Logs L2, Logs L3
WHERE L1.id=L2.id-1 AND L2.id=L3.id-1 AND L1.Num=L2.Num AND L2.Num=L3.Num;


        
        
        
        
        
        



























