1. Find the longest ongoing project for each department.

    SELECT a.name AS department_name,
           b.name AS project_name,
           MAX(end_date-start_date) AS days
    FROM departments a
    INNER JOIN projects b USING(id)
    GROUP BY 1,2
    ORDER BY 1;

| department_name | project_name    | days |
| --------------- | --------------- | ---- |
| HR              | HR Project 1    | 180  |
| IT              | IT Project 1    | 180  |
| Sales           | Sales Project 1 | 183  |

---

2. Find all employees who are not managers.

    SELECT name AS employee_name,
           job_title
    FROM employees
    WHERE job_title NOT ILIKE '%manager%';

| employee_name | job_title       |
| ------------- | --------------- |
| Bob Miller    | HR Associate    |
| Charlie Brown | IT Associate    |
| Dave Davis    | Sales Associate |

---

3. Find all employees who have been hired after the start of a project in their department.

    SELECT a.name,
           hire_date,
           b.name AS department_name,
           c.name AS project_name,
           start_date
    FROM employees a
    INNER JOIN departments b ON a.department_id = b.id
    INNER JOIN projects c USING(department_id)
    WHERE hire_date > start_date
    ORDER BY 3;

| name       | hire_date                | department_name | project_name    | start_date               |
| ---------- | ------------------------ | --------------- | --------------- | ------------------------ |
| Dave Davis | 2023-03-15T00:00:00.000Z | Sales           | Sales Project 1 | 2023-03-01T00:00:00.000Z |

---
 
4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

    SELECT a.name AS employee_name,
           hire_date,
           b.name AS department_name,
           DENSE_RANK() OVER(PARTITION BY b.name
                             ORDER BY hire_date) AS "rank"
    FROM employees a
    INNER JOIN departments b ON a.department_id = b.id
    ORDER BY 3,4;

| employee_name | hire_date                | department_name | rank |
| ------------- | ------------------------ | --------------- | ---- |
| John Doe      | 2018-06-20T00:00:00.000Z | HR              | 1    |
| Bob Miller    | 2021-04-30T00:00:00.000Z | HR              | 2    |
| Jane Smith    | 2019-07-15T00:00:00.000Z | IT              | 1    |
| Charlie Brown | 2022-10-01T00:00:00.000Z | IT              | 2    |
| Alice Johnson | 2020-01-10T00:00:00.000Z | Sales           | 1    |
| Dave Davis    | 2023-03-15T00:00:00.000Z | Sales           | 2    |

---
5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

    SELECT department_name,
           duration
    FROM
      (SELECT a.name AS employee_name,
              hire_date,
              b.name AS department_name,
              LEAD(hire_date, 1) OVER(PARTITION BY b.name
                                      ORDER BY hire_date),
                                 AGE(LEAD(hire_date, 1) OVER(PARTITION BY b.name
                                                             ORDER BY hire_date), hire_date) AS duration
       FROM employees a
       INNER JOIN departments b ON a.department_id = b.id
       ORDER BY 3,
                2) as sq1
    WHERE duration IS NOT NULL;

| department_name | duration                   |
| --------------- | ---------------------------|            
| HR              | 2 years 10 months 10 days  |
| IT              | 3 years 2 months 17 days   |
| Sales           | 3 years 2 months 5 days    |


---

#  Key Insights:

* "Sales Project 1" in the Sales Department is a project that has been ongoing for longer duration in terms of days(183)
* "Bob Miller"," Charles Brown" and "Dave Davis" do not hold the Managerial Positions.
*  Among the three departments, "Sales Department" specifically, had only one individual named "Dave Davis" who was hired after the commencement of a project.

 

