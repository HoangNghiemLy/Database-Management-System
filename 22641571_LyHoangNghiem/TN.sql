--cau b: TN chuyen tiep quyen cua minh cho nhan vien
use AdventureWorks2008R2
grant insert,delete,select on [HumanResources].[EmployeePayHistory] to NV 
--cau c: Tang luong 10% cho NV co Rate <=10
update [HumanResources].[EmployeePayHistory]
set [Rate] = [Rate] * 1.10
where [Rate] <=10 
--cau d: test
--TN khong truy cap duoc vao bang Person.Person. Vi TN duoc admin sap quyen tren bang EmployeePayHistory
select * from Person.Person
--cau e: test
select * from [HumanResources].[EmployeePayHistory]