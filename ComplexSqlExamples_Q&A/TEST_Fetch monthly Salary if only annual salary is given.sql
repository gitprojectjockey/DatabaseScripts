--How to fetch  monthly Salary of Employee if annual salary is given?

select e1.*,(e1.salary/12) as MonthlySalary from employee e1