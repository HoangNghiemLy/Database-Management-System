--tao login va user
use master
create login NV1 with password = '123'
create login NV2 with password ='123'
create login QL with password = '123'

use AdventureWorks2008R2
create user NV1 for login NV1
create user NV2 for login NV2
create user QL for login QL 

--b. tao role NhanVien va phan quyen 
create role NhanVien
go 
grant insert,delete,select,update on [Purchasing].[PurchaseOrderDetail] to NhanVien 

alter role NhanVien
add member NV1
alter role NhanVien
add member NV2
alter role db_datareader
add member QL 
--e. Thu hoi quyen 
alter role NhanVien
drop member NV1
alter role NhanVien
drop member NV2
alter role db_datareader
drop member QL 

drop role NhanVien

--cau 2: 
--a. tao mot transaction tang luon
begin transaction
update e
set Rate = Rate * 1.15 
from [HumanResources].[Shift] as s join [HumanResources].[EmployeeDepartmentHistory] as edh on s.ShiftID=edh.ShiftID
join [HumanResources].[EmployeePayHistory] as e on e.BusinessEntityID=edh.BusinessEntityID
where s.Name like 'Evening'

update e
set Rate = Rate * 1.25 
from [HumanResources].[Shift] as s join [HumanResources].[EmployeeDepartmentHistory] as edh on s.ShiftID=edh.ShiftID
join [HumanResources].[EmployeePayHistory] as e on e.BusinessEntityID=edh.BusinessEntityID
where s.Name like 'Night'
commit transaction 

--backup 
alter database [AdventureWorks2008R2]
set recovery full
backup database [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak' --file 1

--b. xoa moi ban ghi trong bang Sales.TerritoryHistory different Backup
delete Sales.SalesTerritoryHistory

backup database [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak'
with differential --file 2

--Bo sung 
select * from Person.PersonPhone

insert into Person.PersonPhone(BusinessEntityID,PhoneNumber,PhoneNumberTypeID,ModifiedDate)
values (1571,'678-900-123',1,getdate())

backup log [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak' -- file 3

--d. xoa csdl adventurework. Phuc hoi ve buoc c. Kiem tra du lieu
use master
drop database AdventureWorks2008R2

restore database AdventureWorks2008R2
from disk ='E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak'
with file = 1,replace,norecovery

restore database AdventureWorks2008R2
from disk ='E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak'
with file = 2,norecovery

restore database AdventureWorks2008R2
from disk ='E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem_onck\adv2008R2bak.bak'
with file = 3,recovery

-- kiem tra lenh
use AdventureWorks2008R2
select * from HumanResources.EmployeePayHistory
--
select * from Sales.SalesTerritoryHistory
--
select * from Person.PersonPhone
where BusinessEntityID = 1571

