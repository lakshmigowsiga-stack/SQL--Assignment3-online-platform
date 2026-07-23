-- DATABASE --
CREATE DATABASE Online_Learning;
USE Online_Learning;

-- CREATE TABLE --
CREATE TABLE learners (
    learner_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),   -- NULL values allowed
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    purchase_date DATE,
    quantity INT,

    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- INSERT VALUES -- 
INSERT INTO learners
VALUES
(101,'Aarav','India'),
(102,'Lee','Singapore'),
(103,NULL,'USA'),
(104,'Meera',NULL),
(105,'John','Canada');

INSERT INTO courses
VALUES
(201,'SQL for Beginners','Beginner',499.00),
(202,NULL,'Beginner',799.00),
(203,'Excel Masterclass',NULL,599.00),
(204,'Power BI Dashboard','Intermediate',NULL),
(205,'Python for Data Science','Advanced',999.00);

INSERT INTO purchases
VALUES
(301,101,201,'2025-01-05',1),
(302,102,202,'2025-01-10',2),
(303,103,203,NULL,1),
(304,104,204,'2025-02-15',NULL),
(305,105,205,'2025-02-20',1),
(306,101,205,'2025-03-01',2),
(307,102,201,'2025-03-05',1),
(308,105,204,'2025-03-12',1);

-- JOINS --
SELECT
l.full_name AS Learner_Name,
c.course_name AS Course_Name,
c.category AS Category,
p.quantity AS Quantity,
FORMAT(p.quantity * c.unit_price, 2) AS Total_Amount,
p.purchase_date AS Purchase_Date
FROM purchases p
INNER JOIN learners l
ON p.learner_id = l.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

SELECT
l.full_name AS Learner_Name,
c.course_name AS Course_Name,
c.category AS Category,
p.quantity AS Quantity,
FORMAT(p.quantity * c.unit_price, 2) AS Total_Amount,
p.purchase_date AS Purchase_Date
FROM learners l
LEFT JOIN purchases p
ON l.learner_id = p.learner_id
LEFT JOIN courses c
ON p.course_id = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

SELECT
l.full_name AS Learner_Name,
c.course_name AS Course_Name,
c.category AS Category,
p.quantity AS Quantity,
FORMAT(p.quantity * c.unit_price, 2) AS Total_Amount,
p.purchase_date AS Purchase_Date
FROM purchases p
RIGHT JOIN courses c
ON p.course_id = c.course_id
LEFT JOIN learners l
ON p.learner_id = l.learner_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- LEARNERS TOTAL SPENDING WITH THEIR COUNTRY --
SELECT
l.full_name AS Learner_Name,
l.country AS Country,
FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Spending
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country;

-- TOP 3 MOST PURCHASED COURSE --
SELECT
c.course_name AS Course_Name,
c.category AS Category,
SUM(p.quantity) AS Total_Quantity_Purchased
FROM courses c
INNER JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY Total_Quantity_Purchased DESC
LIMIT 3;

-- TOTAL REVENUE AND UNIQUE LEARNERS --
SELECT
c.category AS Category,
FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Revenue,
COUNT(DISTINCT p.learner_id) AS Unique_Learners
FROM courses c
INNER JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category;

-- PURCHASE MORE THAN ONE CATEGORY --
SELECT
l.full_name AS Learner_Name,
COUNT(DISTINCT c.category) AS Categories_Purchased
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1;

-- COURSES NEVER PURCHASED --
SELECT
c.course_id AS Course_ID,
c.course_name AS Course_Name,
c.category AS Category
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
WHERE p.course_id IS NULL;

-- TOTAL SPEND ABOVE AVERAGE LEVEL --
SELECT
l.full_name AS Learner_Name,
FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Spending
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(Total_Spending)
    FROM
    (
        SELECT
            SUM(p.quantity * c.unit_price) AS Total_Spending
        FROM purchases p
        INNER JOIN courses c
        ON p.course_id = c.course_id
        GROUP BY p.learner_id
    ) AS Avg_Spending
);


SELECT * FROM courses;

SELECT
course_name AS Course_Name,
category AS Category,
unit_price AS Unit_Price
FROM courses
WHERE unit_price > ANY
(
    SELECT unit_price
    FROM courses
    WHERE category = 'Beginner'
);

SELECT
l.full_name,
l.country,
SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(Total_Spending)
    FROM
    (
        SELECT
            l2.country,
            SUM(p2.quantity * c2.unit_price) AS Total_Spending
        FROM learners l2
        JOIN purchases p2
        ON l2.learner_id = p2.learner_id
        JOIN courses c2
        ON p2.course_id = c2.course_id
        WHERE l2.country = l.country
        GROUP BY l2.learner_id
    ) AS CountryAvg
);

-- CTE --
WITH LearnerSpending AS
(
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS Total_Spending
    FROM learners l
    INNER JOIN purchases p
        ON l.learner_id = p.learner_id
    INNER JOIN courses c
        ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name
)

SELECT
    learner_id,
    full_name AS Learner_Name,
    Total_Spending
FROM LearnerSpending
WHERE Total_Spending > 10000;

-- CASE --
WITH LearnerSpending AS
(
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS Total_Spending
    FROM learners l
    INNER JOIN purchases p
        ON l.learner_id = p.learner_id
    INNER JOIN courses c
        ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name
)

SELECT
    learner_id AS Learner_ID,
    full_name AS Learner_Name,
    FORMAT(Total_Spending, 2) AS Total_Spending,
    CASE
        WHEN Total_Spending > 15000 THEN 'High Value'
        WHEN Total_Spending BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Learner_Category
FROM LearnerSpending;

-- IFNULL --
SELECT
    c.course_id AS Course_ID,
    c.course_name AS Course_Name,
    c.category AS Category,
    IFNULL(SUM(p.quantity), 0) AS Purchase_Count
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category;

-- CATEGORY PERFORMANCE VIEW -- 
CREATE VIEW category_performance_view AS
SELECT
    c.category AS Category,
    FORMAT(SUM(COALESCE(p.quantity, 0) * COALESCE(c.unit_price, 0)), 2) AS Total_Revenue,
    COUNT(p.purchase_id) AS Number_of_Purchases,
    FORMAT(
        AVG(COALESCE(p.quantity, 0) * COALESCE(c.unit_price, 0)),
        2
    ) AS Average_Revenue_Per_Purchase
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category;

SELECT * FROM category_performance_view;