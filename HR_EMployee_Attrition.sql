create database hr_emp_attrition;
use hr_emp_attrition;

select * from emp_attr;

-- 1. Display the first 10 rows from the table.
select * from emp_attr limit 10;

-- 2. Find the total number of employees in the company.
select count(*) as total_employees from emp_attr;

-- 3. List all unique departments.
select distinct department from emp_attr;

-- 4. Show how many employees have left the company and how many are still working.
select attrition, count(*) as count from emp_attr group by attrition;

-- 5. Retrieve the list of employees who work overtime.
select employeenumber from emp_attr where overtime='yes';

-- 6. Find the average monthly income of all employees.
select round(avg(monthlyincome),2) as avg_monthly_income from emp_attr;

-- 7. Identify employees whose number of companies worked is missing (NULL).
select employeenumber, numcompaniesworked from emp_attr where numcompaniesworked is null;

-- 8. Find the employee(s) with the maximum monthly income.
select employeenumber, monthlyincome from emp_attr 
where monthlyincome=(select max(monthlyincome) from emp_attr);

-- 9. Count the number of employees by gender.
select gender, count(*) as count from emp_attr group by gender;

-- 10.	List all employees who have just joined (YearsAtCompany = 0).
select employeenumber, yearsatcompany from emp_attr where yearsatcompany=0;


-- 11.	Calculate the attrition rate (%) by department.
select department, count(*) as total_employees, 
sum(case when attrition='yes' then 1 else 0 end) as leavers, 
round(sum(case when attrition='yes' then 1 else 0 end)/count(*)*100,2) 
as attrition_rate_pct from emp_attr group by department;

-- 12.	List the top 10 employees with the highest total working years.
select employeenumber, totalworkingyears from emp_attr 
order by totalworkingyears desc limit 10;

-- 13.	Group employees into tenure categories (<1yr, 1–3yr, 4–6yr, 7+yr) and count employees in each.
select
  case
    when yearsatcompany < 1 then '<1yr'
    when yearsatcompany between 1 and 3 then '1-3yr'
    when yearsatcompany between 4 and 6 then '4-6yr'
    else '7+yr'
  end as tenure_group,
  count(*) as count
from emp_attr
group by tenure_group
order by field(tenure_group, '<1yr', '1-3yr', '4-6yr', '7+yr');

-- 14.	Find the average monthly income by job level and attrition status.
select joblevel, attrition, round(avg(monthlyincome), 2) as avg_income
from emp_attr
group by joblevel, attrition
order by joblevel, attrition;

-- 15.	Identify the top 5 job roles with the highest number of employees who left.
select jobrole,
sum(case when attrition = 'yes' then 1 else 0 end) as leavers
from emp_attr
group by jobrole
order by leavers desc
limit 5;

-- 16.	List employees who left the company within their first year.
select employeenumber, jobrole, yearsatcompany
from emp_attr where attrition = 'yes' and yearsatcompany < 1;

-- 17.	Determine the median monthly income of all employees.
with numbered as (
  select
    monthlyincome,
    row_number() over (order by monthlyincome) as rn,
    count(*) over () as total_count
  from emp_attr
)
select round(avg(monthlyincome), 2) as median_income
from numbered
where rn in (
  floor((total_count + 1) / 2),
  ceil((total_count + 1) / 2)
);

-- 18.	Calculate each employee’s approximate new monthly compensation after applying their salary hike percentage.
select employeenumber,
       monthlyincome,
       percentsalaryhike,
       round(monthlyincome * (1 + percentsalaryhike / 100.0), 2) as approx_new_monthly_comp
from emp_attr;

-- 19.	Count employees grouped by overtime status and attrition.
select overtime, attrition, count(*) as count
from emp_attr
group by overtime, attrition;

-- 20.	Display the top 10 employees who attended the most training sessions last year.
select employeenumber, trainingtimeslastyear
from emp_attr
order by trainingtimeslastyear desc
limit 10;

-- 21.	Rank employees by total working years (most experienced = rank 1).
select employeenumber, totalworkingyears,
rank() over (order by totalworkingyears desc) as work_years_rank
from emp_attr;

-- 22.	For each department, find employees whose monthly income is in the top 25% of that department.
select employee_number, department, monthlyincome
from (
  select *,
         cume_dist() over (partition by department order by monthlyincome) as cd
  from emp_attr
) t
where cd >= 0.75
order by department, monthlyincome desc;

-- 23. Divide employees into 10 income deciles and find attrition rate for each decile.
select income_decile,
       count(*) as total_employees,
       sum(case when attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct
from (
  select *,
         ntile(10) over (order by monthlyincome) as income_decile
  from emp_attr
) t
group by income_decile
order by income_decile;


-- 24.	Create a simple risk score based on tenure, performance, overtime, and work-life balance — and list the top 50 high-risk employees.
select employeenumber,
       yearsatcompany,
       performancerating,
       overtime,
       worklifebalance,
       (
         (case when yearsatcompany < 2 then 1 else 0 end)
       + (case when performancerating <= 2 then 1 else 0 end)
       + (case when overtime = 'yes' then 1 else 0 end)
       + (case when worklifebalance <= 2 then 1 else 0 end)
       ) as risk_score
from emp_attr
order by risk_score desc, yearsatcompany asc
limit 50;

-- 25.	Create a summary view showing, for each department and job level: total employees, number of leavers, attrition rate, and average monthly income.
create view dept_attrition_summary as
select department,
       joblevel,
       count(*) as total_employees,
       sum(case when attrition = 'yes' then 1 else 0 end) as leavers,
       round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end) / count(*), 2) as attrition_rate_pct,
       round(avg(monthlyincome), 2) as avg_monthly_income
from emp_attr
group by department, joblevel;









