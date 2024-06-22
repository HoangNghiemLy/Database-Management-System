--cau c: QL xem lai TN va NV da lam
use AdventureWorks2008R2
--TN
select Rate
from [HumanResources].[EmployeePayHistory]

--NV
select *
from [HumanResources].[EmployeePayHistory]
where BusinessEntityID = 3
--cau d: test 
--QL duoc phep truy cap vao bang Person.Person. Vi truong nhom duoc cap quyen db_datareader
select * from Person.Person