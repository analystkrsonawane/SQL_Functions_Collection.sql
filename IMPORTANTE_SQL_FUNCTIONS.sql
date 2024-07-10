--=========================****** SQL FUNCTIONS ******=========================================------------------------------------------
-- CHOOSE : Used to return an item at a specified index from a list of values. 
	select *, choose(1,(january),(february),(march),(april)) AS JANUARY_1 from sales
	
	select *, choose(2,(january),(february),(march),(april)) AS FEBRUARY_2 from sales

	select *, choose(3,(january),(february),(march),(april)) AS MARCH_3 from sales

--------------------------------------------------------------------------------------------------
-------	LEAD AND LAG FUNCTION
--These functions are particularly useful in handling time-series data for comparing 
--sequences of rows within your result set.	
--It has 3 paramerters.
	Purpose: LAG function Helps access data from previous rows in a result set.
	Use Case: Useful when we need to compare a current row with its previous row(s).

	Purpose: Similar to LAG but looks at future rows in a result set.
	Use Case: Useful when you need information from upcoming rows.

use TEST_SQL
select * from REST_CUST_DATA
select *,
	LAG(SPENT_AMOUNT,1,0) OVER (ORDER BY REST_ID,CUST_ID) AS PREVIOUS_SPENT_AMNT_lag,
	lag(visit_date,1) over(order by rest_id,cust_id) as previous_visit,
	lead(visit_date,1) over(order by rest_id,cust_id) as next_visit
from REST_CUST_DATA
							--(In PREVIOUS_SPENT_AMNT we used 0 for replace null values with 0)
-------------------------------------------------------------------------------------------------
--	COALESCE
-- COALESCE functions is used to replace null values with specified values.
-- Replace Null values with 0
drop table null_tbl
	create table null_tbl (
	PRODUCT varchar(20),
	CITY CHAR(20),
	JANUARY INT,
	FEBRUARY INT,
	MARCH INT,
	APRIL INT);

SELECT * FROM NULL_TBL;

INSERT INTO null_tbl VALUES('HP','SAMBHAJINAGAR',NULL,55000,35000,null);
INSERT INTO null_tbl VALUES('DELL',NULL,55000,NULL,65000,90000);
INSERT INTO null_tbl VALUES('APPLE','PUNE',NULL,150000,null,200000);
INSERT INTO null_tbl VALUES('ACER',NULL,75000,NULL,95000,60000);

select * from null_tbl

SELECT
    COALESCE(PRODUCT,'NA') AS PRODUCT_,
	COALESCE(CITY,'NA') AS CITY_,
    COALESCE(JANUARY,0) AS JANUARY_,
    COALESCE(FEBRUARY,0) AS FEBRUARY_,
    COALESCE(MARCH,0) AS MARCH_,
    COALESCE(APRIL,0) AS APRIL_
FROM
    null_tbl;
		--We can use 0 for numerical and "NA" for character data type
--------------------------------------------------------------------------------------------------
--	GREATEST
--"The GREATEST function in SQL is used to retrieve the MAXIMUM numerical value
--from a set of expressions. This function is commonly used in scenarios where WE need to find
--the MAXIMUM value among a set of columns or expressions. 

--Get the highest salling month name as Max_sales_month_name?
DROP TABLE SALES
create table sales (
product varchar(20),
JANUARY INT,
FEBRUARY INT,
MARCH INT,
APRIL INT);

INSERT INTO SALES VALUES('HP',45000,55000,35000,50000);
INSERT INTO SALES VALUES('DELL',55000,57000,65000,90000);
INSERT INTO SALES VALUES('APPLE',37000,150000,46000,200000);
INSERT INTO SALES VALUES('ACER',75000,87000,95000,60000);

select * from sales;

select
	*,
	greatest((JANUARY),(FEBRUARY),(MARCH),(APRIL)) AS Max_sales_values,
	CASE
		WHEN greatest((JANUARY),(FEBRUARY),(MARCH),(APRIL)) = JANUARY THEN 'JANUARY'
		WHEN greatest((JANUARY),(FEBRUARY),(MARCH),(APRIL)) = FEBRUARY THEN 'FEBRUARY'
		WHEN greatest((JANUARY),(FEBRUARY),(MARCH),(APRIL)) = MARCH THEN 'MARCH'
		WHEN greatest((JANUARY),(FEBRUARY),(MARCH),(APRIL)) = APRIL THEN 'APRIL'
	END AS Max_sales_month_name
FROM SALES;
--OR--
SELECT *,
    GREATEST(january, february, march, april) as max_sales,
    CASE GREATEST(january, february, march, april)
        WHEN january THEN 'JANUARY'
        WHEN february THEN 'FEBRUARY'
        WHEN march THEN 'MARCH'
        WHEN april THEN 'APRIL'
    END AS max_sales_month
FROM sales
------------------------------------------------------------------------------------------------
--	LEAST
--"The LEAST function in SQL is used to retrieve the minimum numerical value
--from a set of expressions. This function is commonly used in scenarios where you need to find
--the minimum value among a set of columns or expressions. 
select 
	*,
	least((january),(february),(march),(april)) as MIN_SALES,
	case	
		when least((january),(february),(march),(april)) = JANUARY then 'JANUARY'
		when least((january),(february),(march),(april)) = FEBRUARY then 'FEBRUARY'
		when least((january),(february),(march),(april)) = MARCH then 'MARCH'
		when least((january),(february),(march),(april)) = APRIL then 'APRIL'
	END AS MIN_SALES_MONTH
from sales

SELECT *,
    LEAST(january, february, march, april) as MIN_sales,
    CASE LEAST(january, february, march, april)
        WHEN january THEN 'JANUARY'
        WHEN february THEN 'FEBRUARY'
        WHEN march THEN 'MARCH'
        WHEN april THEN 'APRIL'
    END AS MIN_sales_month
FROM sales
-------------------------------------------------------------------------------------------------
-- FIRST_VALUE AND LAST_VALUES
--Used with window functions to analyze data within a specific context or order.
drop table employee
create table employee(
    emp_id int,
    emp_name varchar(20),
    dept_id int,
    salary int,
    manager_id int,
    emp_age int
);

insert into employee values(1,'Ankit',100,10000,4,39);
insert into employee values(2,'Mohit',100,15000,5,48);
insert into employee values(3,'Vikas',100,10000,4,37);
insert into employee values(4,'Rohit',100,5000,2,16);
insert into employee values(5,'Mudit',200,12000,6,55);
insert into employee values(6,'Agam',200,12000,2,14);
insert into employee values(7,'Sanjay',200,9000,2,13);
insert into employee values(8,'Ashish',200,5000,2,12);
insert into employee values(9,'Mukesh',300,6000,6,51);
insert into employee values(10,'Rakesh',500,7000,6,50);

select * from employee

select
	*,
	first_value(emp_name) over (partition by dept_id order by emp_age desc) as youngest_emp,
	first_value(emp_name) over (partition by dept_id order by salary desc) as dept_highest_salary
from
	employee
----------------------------------------------------------------------------------------------------------
select
	*,
	first_value(emp_name) over (partition by dept_id order by emp_id desc) as oldest_emp_dept,
	first_value(emp_name) over (order by emp_id desc) as oldest_emp_ever,
	first_value(emp_name) over(order by emp_id) as youngest_emp_ever,
	first_value(emp_name) over (partition by dept_id order by salary desc) as max_salary_emp_name, 
	percentile_cont(1) within group (order by salary) over(partition by dept_id) as max_salary
	from employee
------------------------------------------------------------------------------------------------
PERCENTILE_CONT()
--Purpose: Calculates the value at a specified percentile in a dataset.
--For calculate median in sql we don't have any perticular function.
--We can use 2 methods for that.
--	#1 median using row_number
--	#2 median using percentile_cont

--What is median?
--1,2,3,4,5	:	median is 3
--1,24,5,7,11,29,75,88,100	:	median is 24	:	1,5,7,11,(24),29,75,88,100
--2,3,5,7,8,10,13,19,23,25	:	(8+10)/2 = 9	median is 9 in this cased

--FIND THE MEDIAN OF AGE?
select * from employee

--#1 median using row_number
WITH CTE AS (select
	*,
	row_number() over(order by emp_age) as rn_asc,
	row_number() over(order by emp_age desc) as rn_desc
from employee)
(select avg(emp_age) as median_of_age from cte 
	where abs(rn_asc - rn_desc) <=1)
		--This is the first one approch 

--#2 Median using percentile_cont : This is very strate forward method to get median
(select
	*,
	PERCENTILE_CONT(0.5) within group (order by emp_age) over() as Median_of_age,
	PERCENTILE_CONT(.25) within group (order by emp_age) over() as first_quartile,
	percentile_cont(.75) within group (order by emp_age) over () as third_quartile,
	percentile_cont(1) within group (order by emp_age) over() as max_age,
	percentile_cont(0) within group (order by emp_age) over() as min_age,
	percentile_cont(1) within group (order by emp_age) over(partition by dept_id) as max_age_by_dept,
	percentile_cont(1) within group (order by salary) over (partition by dept_id) as max_salary_by_dept
from employee)

-- Why we use within group : Order Specification, Acurate calculation, Flexibility
-----------------------------------------------------------------------------------------------
--	NTILE()
	-- Divides a dataset into specified number of roughly equal parts or "tiles."
USE TEST_SQL
SELECT * FROM orders

select [customer name],sum(sales) as total_sales from orders group by [customer name] 
order by total_sales desc

select top 20 [customer name],sum(sales) as total_sales from orders group by [customer name] 
order by total_sales desc

with CTE AS (
select
	[customer name],
	region,
	sum(sales) as total_sales
from orders
group by [customer name],region
--order by region,total_sales desc
)
	(select *,
			ntile(10) over (partition by region order by total_sales desc) as y from cte)
-------------------------------------------------------------------------------------------------
--PERCENTILE_DISC AND PERCENTILE_CONT 
	--what is difference between percentile_cont and percentile_disc?
PERCENTILE_CONT and PERCENTILE_DISC are both aggregate functions in SQL 
used to calculate percentiles, but they work in slightly different ways:

PERCENTILE_CONT:
Calculation Method: Calculates the continuous percentile.
Result: Returns a value that falls between the two closest values in the ordered dataset.

PERCENTILE_DISC:
Calculation Method: Calculates the discrete percentile.
Result: Returns an actual value from the dataset at the specified percentile.

PERCENTILE_CONT gives a value that may not exist in the original dataset,
but it's somewhere between two existing values.

PERCENTILE_DISC gives you an actual value from the dataset at the specified percentile,
meaning it's one of the values in the dataset.

USE TEST_SQL
select * from employee

select 
	*,
	PERCENTILE_CONT(0.5) within group (order by emp_age) over() as Median_of_age,
	PERCENTILE_DISC(0.5) within group (order by emp_age) over() as Median_of_age
from employee
------------------------------------------------------------------------------------------------
--	PERCENT_RANK in SQL:
Purpose: Calculates the relative standing of a value within a dataset.
Use Case: Useful for understanding the relative position of a value compared to others.
Result: Returns a value between 0 and 1, indicating the percentage of values less than or equal
to the current value.
Example: PERCENT_RANK() OVER (ORDER BY column_name) provides the percent rank for each row based on the ordering of a column.
Simple Explanation:
PERCENT_RANK helps us to know where a specific value stands in comparison to others.
If it gives you a result of 0.6, it means that the value is higher than 60% of the values
in the dataset, and lower than 40%.

select *,
PERCENT_RANK()over(order by emp_age) as x
from employee
----------------------------------------------------------------------------------------------------
***************************CREATE USER DEFINED FUNCTION********************************************
----SCALER FUNCTIONS
--	Scaler function can be used almost anywhere in T-SQL statements.
--	Scaler functions accepts one or more parameters but return only one values.
--	Therefore they must include in return statement.
-- Scalar function can use login such as IF blocks or WHILE LOOPS.
-- Scalar function can not access data. They can access data but this is not a good practise.
-- Scalar funcitons can call others functions.

--CREATE FUNCTION FOR FIND SQUARE
drop function SQR;

CREATE FUNCTION SQR (@z AS INT)
RETURNS INT
AS 
BEGIN
	RETURN(@z * @z)
END

RUN :
SELECT DBO.SQR(5) AS X;

SELECT DBO.SQR(4) AS SQUARE_OF_4
SELECT DBO.SQR(10)

select sqrt(25) as sqrt_root;

---------------------------------------------------------------------------------------------------
--CREATE FUNCTION FOR FIND CUBE
CREATE FUNCTION CUBE (@NUM AS INT)
RETURNS INT
AS 
BEGIN
	RETURN (@NUM * @NUM * @NUM)
END

SELECT DBO.CUBE(9)
-----------------------------------------------------------------------------------------------
--CREATE FUNCTION FOR FIND SQUARE ROOT
drop function sqr_rt
CREATE FUNCTION SQR_RT (@NUM AS INT)
RETURNS FLOAT
AS
BEGIN
    RETURN SQRT(@NUM);
END

SELECT DBO.SQR_RT(25)
select sqrt(25)
-----------------------------------------------------------------------------------------------
-- ALTER TO USER DEFINE FUNCITON
ALTER FUNCTION SQR_RT (@NUM AS INT)
RETURNS FLOAT
AS
BEGIN
    RETURN SQRT(@NUM*@num);
END
SELECT DBO.SQR_RT(3) as result
-------------------------------------------------------------------------------------------------
CREATE FUNCTION CHECK_VOTERS_AGE (@AGE AS INT)
RETURNS VARCHAR(100)
AS 
BEGIN
	DECLARE @STR VARCHAR(100)
	IF @AGE >= 18
	BEGIN
		SET @STR = 'YOU ARE ELIGIBLE TO VOTE'
	END
	ELSE 
	BEGIN
		SET @STR = 'YOU ARE NOT ELIGIBLE TO VOTE'
	END
	RETURN @STR
END

SELECT DBO.CHECK_VOTERS_AGE(19) 
------------------------------------------------------------------------------------------------
-- CREATE USER DEFINED FUNCITON BY USING LOGIC
CREATE FUNCTION dbo.CHK_STATE (@ST VARCHAR(20))
RETURNS VARCHAR(30)
AS 
BEGIN
    DECLARE @STR VARCHAR(30);

    IF @ST = 'WB'
    BEGIN
        SET @STR = 'SUMADHUR';
    END

    ELSE IF @ST = 'MH'
    BEGIN
        SET @STR = 'KARAN';
    END

    ELSE IF @ST = 'MP'
    BEGIN
        SET @STR = 'SAMAR';
    END
    ELSE
    BEGIN
        SET @STR = 'NA';
    END

    RETURN @STR;
END

SELECT dbo.CHK_STATE('WB') AS Result;
-------------------------------------------------------------------------------------------------
drop function today
create function today()
returns datetime
as
begin
	return getdate()
end

select dbo.today()

create function KIRAN (@date date)
returns date
as
begin
	 return GETDATE()
end

select DOB.KIRAN as DOB;

--------------------------------------------------------------------------------------------------
---INLINE TABLE VALUES FUNCTIONS
	Contain a single TSQL statement and return table set
	--Scaler function : It return Scalar values (single value)
	--Inline table value function : It return a table.
We have table 
	use test_sql
	select * from employee

We are going to create inline function
--# WITHOUT PARAMETER
drop function fn_emp2
CREATE FUNCTION fn_emp()
RETURNS TABLE
AS
RETURN (SELECT * FROM employee)

SELECT * FROM fn_emp();

CREATE FUNCTION fn_emp2()
RETURNS TABLE
AS
RETURN (SELECT * FROM employee WHERE DEPT_ID=100)

SELECT * FROM fn_emp2();

CREATE FUNCTION fn_emp3()
RETURNS TABLE
AS
RETURN (SELECT * FROM employee WHERE DEPT_ID<>100)

SELECT * FROM fn_emp3();

CREATE FUNCTION fn_emp4()
RETURNS TABLE
AS
RETURN (SELECT * FROM employee WHERE emp_age>40)

SELECT * FROM fn_emp4();

CREATE FUNCTION fn_emp5()
RETURNS TABLE
AS
RETURN (SELECT * FROM employee WHERE salary>10000)

SELECT * FROM fn_emp5();
--------------------------------------------------------------------------------------------------
-- # WITH SINGAL PARAMETERS
drop function FN_EMP6

CREATE FUNCTION FN_EMP6(@AGE INT)
RETURNS TABLE
AS
RETURN (SELECT * FROM EMPLOYEE WHERE EMP_AGE>=@AGE)

SELECT * FROM FN_EMP6(20)
SELECT * FROM FN_EMP6(50);
------------------------------------------------------------------------------------------------
-- # WITH MULTIPLE PARAMETERS
DROP FUNCTION FN_EMP8
CREATE FUNCTION FN_EMP8(@AGE INT, @DEPT INT,@SLR INT)
RETURNS TABLE
AS
RETURN (SELECT * FROM EMPLOYEE WHERE EMP_AGE>=@AGE AND DEPT_ID=@DEPT AND SALARY>=@SLR)

SELECT * FROM FN_EMP8(20,100,10000)
----------------------------------------------------------------------------------------------------
CREATE FUNCTION FN_EMP9(@AGE INT, @DEPT INT,@SLR INT,@MNGR INT)
RETURNS TABLE
AS
RETURN (SELECT * FROM EMPLOYEE WHERE EMP_AGE>=@AGE AND DEPT_ID=@DEPT AND SALARY>=@SLR AND MANAGER_ID=@MNGR)

SELECT * FROM FN_EMP9(20,100,10000,4)
-------------------------------------------------------------------------------------------------
-- # JOINS
SELECT * FROM FN_EMP9(20,100,10000,4) AS A		
INNER JOIN
EMPLOYEE AS B
ON A.EMP_ID=B.EMP_ID
----------------------------------------------------------------------------------------------------------------
--MULTI STATEMENT TABLE VALUES FUNCTIONS
	--MULTI STATEMENT TABLE VALUES FUNCTIONS IS A TABLE VALUES FUNCTIONS THAT RETURNS THE RESULT
	--OF MULTIPLE STATEMENT
	drop function fn_employee
CREATE FUNCTION FN_EMPLOYEE (@AGE INT)
RETURNS @EMPLOYEE TABLE (ID INT,NAME VARCHAR(20),DEPT_ID INT,SALARY INT,AGE INT)
BEGIN
	INSERT INTO @EMPLOYEE
	SELECT EMP_ID,EMP_NAME,DEPT_ID,SALARY,EMP_AGE FROM EMPLOYEE WHERE EMP_AGE>=@AGE
	RETURN
END
	
SELECT * FROM FN_EMPLOYEE(50)
------------------------------------------------------------------------------------------------------------------------
drop function fn_employeee
CREATE FUNCTION FN_EMPLOYEEE (@AGE INT,@dept int)
RETURNS @EMPLOYEE TABLE (ID INT,NAME VARCHAR(20),DEPT_ID INT,SALARY INT,AGE INT)
BEGIN
	INSERT INTO @EMPLOYEE
	SELECT EMP_ID,EMP_NAME,DEPT_ID,SALARY,EMP_AGE FROM EMPLOYEE WHERE EMP_AGE>=@AGE AND DEPT_ID=@DEPT
	RETURN
END
	select * from employee
SELECT * FROM FN_EMPLOYEEE(20,100)
------------------------------------------------------------------------------------------------
-- # WE CAN WRITE SAME QUERY INTO INLINE TABLE FUNCTIONS
CREATE FUNCTION FN_EMPLO (@AGE INT,@dept int)
RETURNS TABLE
AS
RETURN
(SELECT EMP_ID,EMP_NAME,DEPT_ID,SALARY,EMP_AGE FROM EMPLOYEE WHERE EMP_AGE>=@AGE AND DEPT_ID=@DEPT)

SELECT * FROM FN_EMPLO(50,200)
------------------------------------------------------------------------------------------------------------------
-- # DIFFERENCE BETWEEN INLINE TABLE VALUE FUNCTIONS & MULTIPLE STATEMENT TABLE VALUE FUNCTIONS
-- INLINE TABLE VALUE FUNCTIONS
	In this return clause can not contain the structure of the table.
	In this there are no BEGIN and END clause.
	Inline table values functions are better in performance as compere to multi statement
	table values functions.
	Internally, Inline table values function much like it would a view.

-- MULTI STATEMENT TABLE VALUE FUNCTIONS
	In this we specify the structure of the table with returns clause.
	In this we have to use BEGIN and END clause.
	There is no performance advantage in multi statement table value functions.
	Internally, Multi statement table values function much like it would a stored procedure.
-----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
 CONCAT_WS : It is used to concatenate  2 or more string values with specified delimiter 
			 function argument. 
select concat_ws(' ','Kiran','Sonawane') full_name
SELECT CONCAT_WS(' ','DV','ANALYTICS') INSTITUTE_NAME
select concat_ws(':','Kiran','Sonawane') full_name
select concat_ws('-','Kiran','Sonawane') full_name

SELECT CONCAT_WS(' - ', database_id, recovery_model_desc, containment_desc) AS DatabaseInfo
FROM sys.databases;
select concat_ws('-','kiran','sonawane') as x
select concat_ws('kiran','-','sonawane') as x
select concat_ws(',','kiran','sonawane') as x
select concat_ws(',','kiran','ramesh','sonawane') as x
select concat_ws(' ','kiran','ramesh','sonawane') as x
SELECT * FROM sys.databases;
--------------------------------------------------------------------------------------------------
QUOTENAME : Returns a Unicode string with the delimiters added to make
			the input string a valid SQL Server delimited identifier.

SELECT QUOTENAME('abc def');
select 'kiran ramesh' as ks
select QUOTENAME('kiran sonawane')
select quotename('kiran ramesh')
------------------------------------------------------------------------------------------------
REPLICATE : The REPLICATE function in SQL Server is used to repeat a string a 
			specified number of times. It takes two arguments: the string to be repeated 
			and the number of times to repeat it.
SELECT REPLICATE('KIRAN',3) as no_space
SELECT REPLICATE('JAY HO',4) AS JAI_HO
SELECT REPLICATE('KIRAN ',3) AS one_space
SELECT REPLICATE('KIRAN  ',3) AS two_space
select replicate('RAM ',4) AS RAM;
--------------------------------------------------------------------------------------------------
REVERSE : 
	In SQL Server, the REVERSE function is used to reverse the order of characters in a string.
	It takes a single argument, the string to be reversed.
SELECT REVERSE('KIRAN')
SELECT REVERSE('MAHARASTRA')
SELECT REVERSE('MAAR') AS RAM_G

-------------------------------------------------------------------------------------------------
SPACE : 
In SQL Server, the SPACE function is used to generate a string consisting of a specified 
number of space characters. It takes a single argument,
which represents the number of spaces to generate.
SELECT SPACE(5) AS SPACES
------------------------------------------------------------------------------------------------
STR :
In SQL Server, the STR function is used to convert a numeric expression to a string.
It allows you to specify the precision, length, and style of the result. 
SELECT STR(123.56, 6,4)
SELECT (123.56)
SELECT (123.45) AS NUM;
SELECT STR(234.56) AS CHAR;
-------------------------------------------------------------------------------------------------
TRANSLATE :
The TRANSLATE function is used in SQL Server to replace or remove characters from a string 
based on a translation table.
SELECT TRANSLATE('HELLO WORLD','aeiou','12345') as translate_,
translate('9172549010','12345','abcde') as trans,
translate('850902035683','123','xxx') as x_trans;

------------------------------------------------------------------------------------------------
COALESCE : Coalesce function is used to handle NULL value in SQL.
USE TEST_SQL
select * from med2
select *,coalesce(first_use_dte,'NA') from med2

SELECT *,
       COALESCE(CONVERT(VARCHAR(10), first_use_dte, 120), 'NA') AS first_use_dte_replaced
FROM med2;
-----------------------------------------------------------------------------------------------
drop table person
CREATE TABLE Person (
    Name VARCHAR(50),
    Age INT NULL
);

INSERT INTO Person (Name, Age) VALUES
('John', 25),
('Alice', 30),
('Bob', 22),
('Emma', NULL),
('Michael', 28),
('Sarah', NULL),
('David', 35),
('Olivia', NULL),
('James', 29),
('Sophia', 27),
('William', 32),
('Charlotte', NULL),
('Daniel', 31),
('Emily', NULL),
('Matthew', 26),
('Ava', 33),
('Jacob', NULL),
('Grace', 24),
('Ethan', 34),
('Mia', 23);

select * from person;
select *, coalesce(age,(select avg(age) from person)) as mdf_Age from person;	--Using sub-query
select * from person
------------------------------------------------------------------------------------------------
ROUND : ROUND function is used to round a numeric value to a specified number of decimal places. 
SELECT ROUND(123.4567, 0) AS RoundedNumber;
select round(cast(123.4567 as float),2) as x
select round(cast(123.4567 as int),2) as x
select round(245.243,2) as round_fn
select cast(245.243 as int) as int_fn			-- Convert data type as integer 
select round(12.34,2) as round1
--------------------------------------------------------------------------------------------------------
--NULLIF
The NULLIF function is used to compare two expressions.
If the expressions are equal, NULLIF returns a null value; 
otherwise, it returns the first expression. The purpose of NULLIF is to handle cases
where you want to return a null value if two expressions are equal.

select * from INFORMATION_SCHEMA.columns

select *,nullif(SALARY,2000) as NULL_SALARY,nullif(age,27) as NULL_AGE from customers
--------------------------------------------------------------------------------------------------------------------
--PARSE :  
PARSE function is used to convert a string representation of a date and/or time 
into a datetime or datetime2 data type. 
SELECT PARSE('2022-02-28' AS datetime) AS ParsedDate;
SELECT PARSE('13-12-1998' AS DATETIME) AS parsedate
SELECT PARSE('12-13-1998' AS DATETIME) AS parsedate
SELECT PARSE('12-10-1998' AS DATETIME) AS parsedate
SELECT PARSE('03-28-1998' AS DATETIME) AS parsedate
-------------------------------------------------------------------------------------------------
--TRY_CAST
TRY_CAST function is used to attempt to convert a value to a specified data type. 
If the conversion is successful, it returns the converted value; otherwise, it returns NULL.

SELECT TRY_CAST('123' AS int) AS ConvertedInt
SELECT TRY_CAST(3.14 AS INT) AS ConvertedDecimal
SELECT TRY_CAST('2022-02-28' AS datetime) AS ConvertedDateTime;
SELECT TRY_CAST('2022-02-28' AS char) AS ConvertedDateTime;
SELECT TRY_CAST('2022-02-28' AS int) AS ConvertedDateTime;
------------------------------------------------------------------------------------------------
TRY_PARSE function is used to parse a string representation of a date and/or time into a
datetime or datetime2 data type. Similar to TRY_CONVERT, TRY_PARSE provides a way to attempt 
parsing with a more flexible approach, allowing you to specify a format.
SELECT TRY_PARSE('2022-02-28' AS datetime) AS ParsedDate;
SELECT TRY_CONVERT(DATETIME,'2022-02-28') AS ParsedDate;
-------------------------------------------------------------------------------------------------
ISDATE : USED TO VALIDATE THAT GIVEN FORMAT WHETHER DATE OR NOT
SELECT ISDATE('22-12-1999') AS X
-------------------------------------------------------------------------------------------------
ABS : ABS function is used to return the absolute (non-negative) value of a numeric expression.
Whether the original value is positive or negative, the ABS function will return its positive counterpart.

SELECT ABS(-1)
------------------------------------------------------------------------------------------------
RAND() :RAND() function is used to generate a random float value from 0 through 1.
This function does not take any parameters 
and produces a random number each time it is called within a query.
SELECT round(RAND()*100,0),round(RAND()*100,0),round(RAND()*100,0),round(RAND()*100,0),round(RAND()*100,0)
-------------------------------------------------------------------------------------------------
-- Generate a random number between 1 and 100
SELECT FLOOR(RAND() * 100) AS RandomNumber INTO TABLE_x UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber UNION 
SELECT FLOOR(RAND() * 100) AS RandomNumber 
SELECT * FROM TABLE_x
-----------------------------------------------------------------------------------------------------
IIF : The IIF function is a logical function in SQL Server that returns one of two values based
on the evaluation of a specified condition. It is a shorthand way of writing a CASE expression 
with two branches.

use test_sql
select *,iif(sales_amount >=5000,'high sales','low sales') from Employees
------------------------------------------------------------------------------------------------
SQUARE : function is used to return the square of a numeric expression.
select SQUARE(5) as square_of_5
select SQUARE(6) as square_of_6
select SQUARE(7) as square_of_7
------------------------------------------------------------------------------------------------
sqrt : calculate the square root of a numeric expression, you can use the SQRT function. 
The SQRT function returns the square root of the specified numeric expression.
select sqrt(25) as _squaroot_25_
------------------------------------------------------------------------------------------------
ISNULL()		-- very important
function in SQL is used to replace NULL with a specified replacement value. 
It takes two arguments: the expression to be checked for NULL, 
and the value to be returned if the expression is NULL.
-- Create a table
DROP TABLE EXAMPLETABLE1
CREATE TABLE ExampleTable1 (
    ID INT,
    SALARY INT
);

-- Insert data with NULL values
INSERT INTO ExampleTable1 (ID, SALARY)
VALUES
    (1, NULL),
    (2, 4500),
    (3, 5600),
    (4, 3340),
	(5, NULL),
	(6, 9485),
	(7, 3413),
	(8, 5000),
	(9, NULL),
	(10, 5600),
	(11, NULL),
	(12, 6900);
	
select * from ExampleTable1
select avg(salary) as avg_salary from exampleTable1
select avg(isnull(salary,0)) as avg_salary from exampletable1

-- USE OF ISNULL()
	select avg(isnull(salary,0)) as average_salary from ExampleTable1 
	select avg(salary) as average_salary from exampletable1
When we calculate average having null records then null records does not consider. 
Thats why we have to use isnull() fn with 0. 

--update ExampleTable1
--set name = cast(name as int) 

select * from exampletable1

--update exampletable1
--set name =try_cast(name as int)				-- Change data type

-- Use ISNULL() to replace NULL with a default/AVG_AGE value
UPDATE exampleTable1
SET salary = (SELECT AVG(ISNULL(salary, 0)) FROM exampleTable1)
WHERE salary IS NULL;
-- null values perfectly replace with avg_age
select * from exampleTable1
------------------------------------------------------------------------------------------------
select avg(isnull(salary,0)) as avg_salary from exampletable1

update exampletable1
set salary = (select avg(isnull(salary,0)) as avg_salary from exampletable1)
where salary is null

select * from exampletable1
-----------------------------------------------------------------------------------------------
-- string_agg --
drop table ExampleTable2

CREATE TABLE ExampleTable2 (
    ID INT,
    FruitName VARCHAR(50)
);

-- Insert some sample data
INSERT INTO ExampleTable2 (ID, FruitName)
VALUES 
    (1, 'Apple'),
    (1, 'Banana'),
    (2, 'Orange'),
    (2, 'Grapes');

select * from ExampleTable2

select string_agg(FruitName,', ') asx from ExampleTable2
-----------------------------------------------------------------------------------------------
-- Creating the table
CREATE TABLE ExampleTable (
    Name VARCHAR(50)
);

-- Inserting data into the table
INSERT INTO ExampleTable (Name) VALUES ('Alice');
INSERT INTO ExampleTable (Name) VALUES ('Bob');
INSERT INTO ExampleTable (Name) VALUES (NULL);  -- This includes a NULL value
INSERT INTO ExampleTable (Name) VALUES ('Charlie');
INSERT INTO ExampleTable (Name) VALUES (NULL);  -- Another NULL value

select * from ExampleTable
select *, isnull(name,'NA') from ExampleTable
select *,coalesce(name,'NA') from ExampleTable
------------------------------------------------------------------------------------------------------------------------
-- ** COLLATION : CASE SENSITIVE COMPARISON IN CASE-SENSITIVE. **
-- Retrieve the only Upper case email id?
-- Retrieve only the Lower case email_id?

-- Collation in SQL refers to the set of rules that determine how data is sorted and compared,
-- including case sensitivity and accent marks.

drop table employee

CREATE TABLE employee (
employee_id int,
employee_name varchar(15),
email_id varchar(15) );

INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('101','Liam Alton', 'li.al@abc.com');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('102','Josh Day', 'jo.da@abc.com');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('103','Sean Mann', 'se.ma@abc.com');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('104','Evan Blake', 'ev.bl@abc.com');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('105','Toby Scott', 'jo.da@abc.com');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('106','Anjali Chouhan', 'JO.DA@ABC.COM');
INSERT INTO employee (employee_id,employee_name, email_id) VALUES ('107','Ankit Bansal', 'AN.BA@ABC.COM'); 

SELECT * FROM EMPLOYEE

select * from employee
where email_id collate latin1_general_bin = upper(email_id)

select * from employee
where email_id collate latin1_general_bin=upper(email_id)

-- COLLATION IS APPLIED AT FOUR LEVELS.
-- * INSTANCE
-- * DATABASE
-- * COLUMN
-- * QUERY

SELECT SERVERPROPERTY(*collation*) as servercollation;
select name,database_id,collation_name from sys.databases


