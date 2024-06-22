--cau c: Xoa du lieu NV co BusinessEntityID = 3
use AdventureWorks2008R2
delete [HumanResources].[EmployeePayHistory]
where BusinessEntityID = 3 
--test update
update [HumanResources].[EmployeePayHistory]
set Rate = 10
where BusinessEntityID = 3
--cau d:test
--NV khong the xem bang Person.Person. Vi NV duoc truong nhom cap quyen tren bang EmployeePayHistory
select * from Person.Person
--cau e: test
select * from [HumanResources].[EmployeePayHistory]