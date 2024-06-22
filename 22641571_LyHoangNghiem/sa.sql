--a. tao login
use master
create login TN with password = '123'
create login NV with password = '123'
create login QL with password ='123'
--tao user
use AdventureWorks2008R2
create user TN for login TN
create user NV for login NV
create user QL for login QL 
--phan quyen: admin chi cap quyen cho TN va QL 
grant insert,update,delete,select on [HumanResources].[EmployeePayHistory] to TN with grant option 
exec sp_addrolemember 'db_datareader','QL'
deny update on [HumanResources].[EmployeePayHistory] to NV
--cau d:
--Nhan vien khong the sua 1 dong du lieu tuy y. Vi da bi admin tu choi 
--Chi co user QL moi co the xem bang Person.Person

--cau e: Thu hoi quyen TN va NV
revoke insert,delete,update,select on [HumanResources].[EmployeePayHistory] to TN cascade 

--phan 2: backup va restore
--cau a: giao thuc tang luong 10% cho sale & mar. 5% cho cac phong con lai
begin transaction
update e
set Rate = Rate * 1.10
from HumanResources.EmployeePayHistory as e
inner join HumanResources.EmployeeDepartmentHistory as edh on e.BusinessEntityID=edh.BusinessEntityID
inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
where d.Name in ('Sales','Marketing')

update e
set Rate = Rate * 1.05
from HumanResources.EmployeePayHistory as e
inner join HumanResources.EmployeeDepartmentHistory as edh on e.BusinessEntityID=edh.BusinessEntityID
inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
where d.Name not in ('Sales','Marketing')
commit transaction 
--backup
alter database [AdventureWorks2008R2]
set recovery full

backup database [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak' --file 1

--cau b: xoa moi ban ghi purcharse.Oderdetail. Differential Backup
delete Purchasing.PurchaseOrderDetail

backup database [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak'
with differential  --file 2

--cau c: 
delete Person.EmailAddress
WHERE BusinessEntityID = 4;


select * from HumanResources.Employee
where BusinessEntityID = 4

backup log [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak' --file 3

--cau e: xoa csdl. Phuc hoi ve buoc c
use master
drop database AdventureWorks2008R2

restore database [AdventureWorks2008R2]
from disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak'
with file = 1, replace, norecovery 

restore database [AdventureWorks2008R2]
from disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak'
with file = 2, norecovery 

restore database [AdventureWorks2008R2]
from disk = 'E:\HE  QUAN TRI CSDL - BAITAP\22641571_LyHoangNghiem\adv2008R2bak.bak'
with file = 3, recovery 

/*
Viết after trigger trên bảng ProductReview sao cho khi cập nhật 1 bình luận (Comments) 
cho 1 mã sản phẩm thì liệt kê danh sách thông tin liên quan của sản phẩm gồm ProductID, 
Color, StandardCost, Rating, Comments; nếu mã sản phẩm không có thì báo lỗi và quay lui 
giao tác. Viết lệnh kích hoạt trigger cho 2 trường hợp (1đ)
*/
use AdventureWorks2008R2
go
select * from [Production].[ProductReview]
go

create trigger sp_3 on [Production].[ProductReview]
after update
as
begin
	declare @ma int
	set @ma = (select ProductID from inserted)
	if exists(select * from Production.ProductReview where ProductID = @ma)
	SELECT    Production.Product.ProductID, Production.Product.Color, Production.Product.StandardCost, Production.ProductReview.Rating, Production.ProductReview.Comments
	FROM      Production.Product INNER JOIN
              Production.ProductReview ON Production.Product.ProductID = Production.ProductReview.ProductID
	else
		begin
			print'Khong tim thay san pham'
			rollback
		end
end

--thuc thi 
update Production.ProductReview
set Comments = 'aaa'
where ProductReviewID = 1
--truong hop sai
update Production.ProductReview
set Comments = 'mancity'
where ProductReviewID = 10

