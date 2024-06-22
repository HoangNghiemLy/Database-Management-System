--Tuần 03: 
--1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table MyDepartment(
DepID smallint not null primary key,
DepName nvarchar(50),
GrpName nvarchar(50))

create table MyEmployee(
EmpID int not null primary key,
FrstName nvarchar(50),
MidName nvarchar(50),
LstName nvarchar(50),
DepID smallint not null foreign key references MyDepartment(DepID))

--2) Dùng lệnh insert <TableName1> select <fieldList> from 
--<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ 
--bảng [HumanResources].[Department].
insert MyDepartment select DepartmentID, Name, GroupName
from [HumanResources].[Department] 

select *from MyDepartment



--3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu 
--từ 2 bảng
--[Person].[Person] và 
--[HumanResources].[EmployeeDepartmentHistory]

insert MyEmployee select top 20 p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,h.DepartmentID
from [Person].[Person] as p inner join [HumanResources].[EmployeeDepartmentHistory] as h 
on p.BusinessEntityID=h.BusinessEntityID
where h.DepartmentID=1
order by p.BusinessEntityID


select *from MyEmployee
--chạy lần lượt các lệnh kiểm tra xem dữ liệu các phòng ban
select * from [Person].[Person]


insert MyEmployee select top 4 p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,h.DepartmentID
from [Person].[Person] as p inner join [HumanResources].[EmployeeDepartmentHistory] as h
on p.BusinessEntityID=h.BusinessEntityID
where h.DepartmentID=1
order by p.BusinessEntityID

go
insert MyEmployee select top 8 p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,h.DepartmentID
from [Person].[Person] as p inner join [HumanResources].[EmployeeDepartmentHistory] as h
on p.BusinessEntityID=h.BusinessEntityID
where h.DepartmentID=3
order by p.BusinessEntityID
go
insert MyEmployee select top 8 p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,h.DepartmentID
from [Person].[Person] as p inner join [HumanResources].[EmployeeDepartmentHistory] as h
on p.BusinessEntityID=h.BusinessEntityID
where h.DepartmentID=7
order by p.BusinessEntityID

go
select *from MyEmployee

--4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
--có thực hiện được không? Vì sao?

select *from MyDepartment --bảng cha
select *from MyDepartment where DepID =1 -- bảng con

--Xóa phòng ban DepID=1 ở bảng cha
delete from MyDepartment where DepID = 1
--Không xóa được vì vi phạm ràng buộc khóa ngoại, vì bảng con có dữ liệu mất tham chiếu khóa ngoại 
--Cần xóa sạch bảng con thông tin liên quan bảng cha cần xóa
--khi khai báo ràng buộc khóa ngoại cần khai báo on delete cascade 


--5) Thêm một default constraint vào field DepID trong bảng MyEmployee, 
--với giá trị mặc định là 1.
use AdventureWorks2008R2
alter table MyEmployee
add constraint def_MyEmployee default 1 for DepID


--6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau: 
--insert into MyEmployee (EmpID, FrstName, MidName, 
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị 
--trong field depID của record mới thêm.

select *from MyEmployee
insert into MyEmployee(EmpID, FrstName, MidName,LstName)
values (26,'Nguyen','Nhat','Nam')

select *from MyEmployee

--7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại 
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
--delete set default.
alter table [dbo].[MyEmployee]
drop constraint [FK__MyEmploye__DepID__592635D8]

--Thiết lập khóa ngoại, xóa khóa ngoại đã tồn tại  on delete set default

alter table MyEmployee with nocheck 
add constraint [FK_MyEmployee] foreign key(DepID) references MyDepartment(DepID)
on delete set default 

--8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả 
--trong hai bảng MyEmployee và MyDepartment

delete from MyDepartment where DepID = 7 

--kiểm tra bảng MyDepartment
select *from MyDepartment -- kiểm tra bảng cha vừa xóa
go
select *from MyEmployee -- kiểm rta 

--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa 
--ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete 
--cascade và on update cascade
alter table [dbo].[MyEmployee]
drop constraint FK_MyEmployee 

alter table [dbo].[MyEmployee] with nocheck
add constraint FK__MyEmployee foreign key(DepID)
references MyDepartment(DepID)
on delete cascade 
on update cascade 



--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có 
--thực hiện được không?
delete from MyDepartment where DepID =3

--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturing

alter table [dbo].[MyDepartment] 
add constraint ck_Mydept check (GrpName='Manufacturing')

--bị lỗi
alter table [dbo].[MyDepartment]
with nocheck 
add constraint ck_Mydept check(GrpName='Manufacturing')

insert MyDepartment values (17,'Peter','Quality Assurance')
--ko chèn được do ràng buộc phải chèn vào Manufacturing

--chèn được 
insert MyDepartment values (7,'Peter','Manufacturing')
insert MyDepartment values (18,'Lisa','Manufacturing')

--xem lại dữ liệu
select *from MyDepartment

--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột 
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60

alter table [HumanResources].[Employee]
with nocheck
add constraint Ck_Emp check (((year(getdate())-year(BirthDate) >=18 )) and ((year(getdate()) -year (BirthDate))<=60))







--Module 3:
--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng 
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate

go
create view vw_Products 
as
select p.ProductID, Name,Color, Size, Style, p.StandardCost,ch.EndDate,ch.StartDate
from [Production].[Product] as p join [Production].[ProductCostHistory] as ch 
on p.ProductID = ch.ProductID

go
select *from [dbo].[vw_Products] 
exec sp_helptext [vw_Products]


--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.

create view List_Product_View 
as 
select p.ProductID,Name as Product_Name, CountOfOrder = COUNT(h.SalesOrderID), Sum = SUM(OrderQty * UnitPrice)
from [Production].[Product] as p join [Sales].[SalesOrderDetail] as od on p.ProductID=od.ProductID
join Sales.SalesOrderHeader as h on h.SalesOrderID=od.SalesOrderID
where DATEPART(q,OrderDate) = 1 and YEAR(OrderDate) = 2008
group by p.ProductID,Name
having SUM(OrderQty * UnitPrice) > 10000 and COUNT(h.SalesOrderID) > 500
go

select *from [dbo].[List_Product_View]
--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS 
--OrderMonth, SUM(TotalDue).
go
create view vw_CustomerTotals
as
select CustomerID,YEAR(OrderDate) as OrderYear, MONTH(OrderDate) as OrderMonth
from [Sales].[SalesOrderHeader]
group by CustomerID, YEAR(OrderDate),MONTH(OrderDate)

go
select *from [dbo].[vw_CustomerTotals]





--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
go
create view sumOfQuantity
as
select SalesPersonID, OrderYear = YEAR(OrderDate), sumOfOderQty = SUM(OrderQty)
from [Sales].[SalesOrderHeader] as h join [Sales].[SalesOrderDetail] as od on h.SalesOrderID=od.SalesOrderID
group by h.SalesPersonID, YEAR(OrderDate)
go

select * from [dbo].[sumOfQuantity]


--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên 
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

go
create view ListCustomer_view
as
select BusinessEntityID as PersonID, FirstName+' '+LastName as FullName, CountOfOrders=COUNT(h.SalesOrderID)
from [Sales].[SalesOrderHeader] as h join [Person].[Person] as p on h.CustomerID=p.BusinessEntityID
where YEAR(OrderDate)>2007 and YEAR(OrderDate)<2008
group by BusinessEntityID, FirstName+' '+LastName, YEAR(OrderDate)
having COUNT(h.SalesOrderID)>25

go
select *from [dbo].[ListCustomer_view]



--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông 
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
go
create view ListProduct_view 
as
select p.ProductID,Name, sumOfQuantity = SUM(OrderQty), YEAR(OrderDate) as OderYear
from [Production].[Product]  as p join [Sales].[SalesOrderDetail] as od on p.ProductID=od.ProductID
join [Sales].[SalesOrderHeader] as odh on odh.SalesOrderID=od.SalesOrderID
where Name like 'Bike%' or Name like 'Sport%'
group by p.ProductID,Name,YEAR(OrderDate)
having SUM(OrderQty) > 50

go

select * from [dbo].[ListProduct_view]

--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
go
create view List_department_View 
as
select d.DepartmentID,Name,avgofRate=AVG(Rate)
from [HumanResources].[Department] as d join [HumanResources].[EmployeeDepartmentHistory] as edh on d.DepartmentID=edh.DepartmentID
join [HumanResources].[EmployeePayHistory] eph on eph.BusinessEntityID=edh.BusinessEntityID
group by d.DepartmentID,Name
having AVG(Rate) > 30

go
select * from [dbo].[List_department_View]





--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm 
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
go
create view Sales.vw_OrderSummary
with encryption 
as
select OrderYear=YEAR(OrderDate), OrderMonth = MONTH(OrderDate), OderToTal = SUM([OrderQty] * [UnitPrice])
from [Sales].[SalesOrderHeader] as odh join  [Sales].[SalesOrderDetail] as sod on odh.SalesOrderID=sod.SalesOrderID
group by YEAR(OrderDate), MONTH(OrderDate)

go
exec sp_helptext [List_Product_View]
exec sp_helptext [Sales.vw_OrderSummary]


--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng 
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng 
--Product. Có xóa được không? Vì sao?
go
create view Production.vwProducts
with Schemabinding -- rang buoc ve so do
as
select p.ProductID, Name, pc.StartDate, pc.EndDate, p.ListPrice
from [Production].[Product] as p join [Production].[ProductCostHistory] as pc on p.ProductID=pc.ProductID

go
select * from [Production].[vwProducts]


--Ko xoa duoc cot ListPrice trong bang Product vi co rang buoc
alter table [Production].[Product]
drop column [ListPrice]

--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các 
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
go 
create view view_Department
as
select DepartmentID, Name, GroupName
from [HumanResources].[Department]
where GroupName = 'Manufacturing' or GroupName='Quality Assurance'
with check option

--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.

--xem du lieu dang co
select DepartmentID, Name, GroupName
from [HumanResources].[Department]

--chen phong ban khong duoc nhap
insert view_Department(Name,GroupName)
values('New Dept','Inventory Management')

--error: The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
--The statement has been terminated.

-- chen duoc:
insert view_Department(Name,GroupName)
values('New Dept','Quality Assurance')

--Kiem tra:
select * from dbo.view_Department
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một 
--phòng thuộc nhóm “Quality Assurance”.
insert view_Department(Name,GroupName)
values ('abc dept','Manufacturing')

insert view_Department(Name,GroupName)
values('def dept','Quality Assurance')

--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
select * from dbo.view_Department
select * from MyDepartment



