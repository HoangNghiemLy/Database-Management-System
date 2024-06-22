--Tu?n 8: backup và restore database
--1. Các loai backup: xem lai ly thuyet (quan trong)
----Full backup
----Differential backup
----Transaction Log backup

--2. Recovery (restore): Phuc hoi database dua trên các bang backup đa có 
----1. Nguyên tac:
-----gia đinh là database bi hư hong (ko the truy suat) / bi xóa (các file mdf, ndf, ldf b? xóa)
-----=> bu?c ph?i có t?i thi?u 1 full backup
-----=> l?nh restore đ?u tiên luôn luôn là restore t? b?ng full backup

--3. Ch?n Recovery Mode(?)
-----Simple Recovery model: cho phép thuc hien full+differential backup
-----Full Recovery model: cho phép thuc hien full backup + differential backup+ log backup

--===========================================================================================
----------------------------------------------------------------------------------------------

--1. Trong SQL Server, tao thiet bi backup có tên adv2008back lưu trong thư m?c 
--T:\backup\adv2008back.bak
exec sp_addumpdevice 'disk','adv2008back','E:\HE  QUAN TRI CSDL - BAITAP\backup\adv2008back.bak';
--hoac dùng tool (Object Explore)\server backup
---
exec sp_dropdevice 'adv2008back'
go

--2. Attach CSDL AdventureWorks2008, ch?n mode recovery cho CSDL này là full, r?i 
--thuc hien full backup vào thiet bi backup vua tao

--chon mode recovery cho CSDL này là full, roi thuc hien full backup vào thiet bi backup vua tao 
--explore \option\recorvery mode th?y simply
use master 
go
alter database [AdventureWorks2008R2] set recovery full; 

--t1: full backup
backup database [AdventureWorks2008R2]  --ghi l?i File = 1
to adv2008back
with format;

--tương đương
backup database [AdventureWorks2008R2]
to disk = 'E:\HE  QUAN TRI CSDL - BAITAP\backup\AdventureWorks2008R2.bak'
with differential , description ='AdventureWorks2008R2.bak backup full'
go

--3. Mo CSDL AdventureWorks2008, tao mot transaction giam giá tat ca mat hàng xe 
--đ?p trong bang Product xuong $15 neu tong tri giá các mat hàng xe đap không thap 
--hơn 60%.

--nhin bang product

--tim hieu CSDL:
--công ty AdventureWorks2008R2 kinh doanh các mat hàng gi?
use AdventureWorks2008R2
select * from Production.ProductCategory
where Name = 'Bikes'  --Bikes thuoc ProductCategory = 1

--có may loai xe đap, ke tên 
select *
from Production.ProductSubcategory
where ProductCategoryID = 1

--loc ra các mat hàng là xe đap:
select ProductID, Name, ListPrice  
from Production.Product
where ProductSubcategoryID 
in (
	select ProductCategoryID
	from Production.ProductSubcategory
	where ProductCategoryID=1
)

--tao mot transaction giam giá tat ca các mat hàng xe đap trong bang Product
--xuong $15 neu tong giá tri các mat hàng xe đap không thap hơn  60%
begin tran
declare @tongxedap money, @tong money
set @tongxedap = (select sum(ListPrice)  from Production.Product
					where ProductSubcategoryID in (
						select ProductSubcategoryID from Production.ProductSubcategory
						where ProductCategoryID = 1)
				)
set @tong = (select sum(ListPrice) from Production.Product)

if @tongxedap / @tong >= 0.6
	begin
		update Production.Product
		set ListPrice = ListPrice -15 -- giảm giá
		where ProductSubcategoryID in(
			select ProductCategoryID from Production.ProductSubcategory
			where ProductCategoryID = 1)
		commit tran
	end 
else --tỷ lệ xe đạp thấp hơn 60%
	rollback tran
go

--xem lại giá xe đạp sau khi giảm
select ProductID, Name, ListPrice
from Production.Product 
where ProductSubcategoryID in (
	select ProductCategoryID from Production.ProductSubcategory
	where ProductCategoryID = 1)


--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu 
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup 
use AdventureWorks2008R2
begin tran
update Production.Product set Name='ttt' where ProductID = 1
commit 
go
--b. differential backup
backup database [AdventureWorks2008R2] --ghi lại File =2
to adv2008back 
with Differential 


--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
--Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup

delete from Person.EmailAddress


--t3
backup database [AdventureWorks2008R2] --ghi lại file 3
to adv2008back
with differential 

go
drop table Person.EmailAddress

go

--t4: log backup
backup log [AdventureWorks2008R2]
to adv2008back 

--6. Thực hiện lệnh:
--a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như 
--sau:
INSERT INTO Person.PersonPhone VALUES (10000,'123-456-
--7890',1,GETDATE())
--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị 
--backup vừa tạo. 


--t5:
backup database [AdventureWorks2008R2] 
to adv2008back
with differential 
--c. Chú ý giờ hệ thống của máy. 
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem
--7. Xóa CSDL AdventureWorks2008
use master
go
drop database [AdventureWorks2008R2]
go
--8. Để khôi phục lại CSDL: 
--a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào? 
--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn 
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL 
--AdventureWorks2008 ra sao?
--9. Thực hiện đoạn lệnh sau:
--CREATE DATABASE Plan2Recover;
--USE Plan2Recover;
--CREATE TABLE T1 (
---32-
--Bài tập Thực hành Hệ Quản Trị Cơ sở Dữ Liệu
---33-
--PK INT Identity PRIMARY KEY,
--Name VARCHAR(15)
-- );
--GO
--INSERT T1 VALUES ('Full');
--GO
--BACKUP DATABASE Plan2Recover
--TO DISK = 'T:\P2R.bak'
--WITH NAME = 'P2R_Full',
--INIT;
--Tiếp tục thực hiện các lệnh sau:
--INSERT T1 VALUES ('Log 1');
--GO
--BACKUP Log Plan2Recover
--TO DISK ='T:\P2R.bak'
--WITH NAME = 'P2R_Log';
--Tiếp tục thực hiện các lệnh sau:
--INSERT T1 VALUES ('Log 2');
--GO
--BACKUP Log Plan2Recover
--TO DISK ='T:\P2R.bak'
--WITH NAME = 'P2R_Log';
--Xóa CSDL vừa tạo, rồi thực hiện quá trình khôi phục như sau:
--Use Master;
--RESTORE DATABASE Plan2Recover
--FROM DISK = 'T:\P2R.bak'
--With FILE = 1, NORECOVERY;
--RESTORE LOG Plan2Recover
--FROM DISK ='T:\P2R.bak'
--With FILE = 2, NORECOVERY;
--RESTORE LOG Plan2Recover
--FROM DISK ='T:\P2R.bak'
--With FILE = 3, RECOVERY;