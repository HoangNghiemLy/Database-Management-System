--Câu 2: Sử dụng T-SQL tạo một cơ sở dữ liệu mới tên  SmallWorks, với 2 file group tên
--SWUserData1 và SWUserData2, lưu theo đường dẫn T:\HoTen\TenTapTin.
create database SmallWorks

on primary
(
	Name = 'SmallWorksPrimary',
	FILENAME = 'T:\LyHoangNghiem\SmallWorks.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData1
(
	Name = 'SmallWorksData1',
	FILENAME = 'T:\LyHoangNghiem\SmallWorksData1.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE =50MB
),
FILEGROUP SWUserData2
(
	NAME = 'SmallWorksData2',
	FILENAME = 'T:\LyHoangNghiem\SmallWorksData2.ndf',
	SIZE = 10MB,
	FILEGROWTH = 50MB,
	MAXSIZE = 50MB
)
LOG ON
(
	NAME = 'SmallWorks_log',
	FILENAME = 'T:\LyHoangNghiem\SmallWorks_log.ldf',
	SIZE = 10MB,
	FILEGROWTH = 10%,
	MAXSIZE = 20MB
)
--Câu 3: Dùng SSMS để xem kết quả: Click phải trên tên của CSDL vừa  tạo
--a.  Chọn filegroups, quan sát kết  quả:
--Có bao nhiêu filegroup, liệt kê tên các filegroup hiện  tại

-----Có 3 FileGroup:  PRIMARY, SWUserData1, SWUserData2

-- Filegroup mặc định là gì?
-----FILEGROUP mặc định là PRIMARY


--b.  Chọn file, quan sát có bao nhiêu database  file?
------Có 4 database file: SmallWorksPrimary, SmallWorksData1, SmallWorksData2, SmallWorks_log


--Câu 4: Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add 
--thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1. 
--Dùng SSMS xem kết  quả.


alter database [SmallWorks] add filegroup Test1FG1

alter database [SmallWorks] add file(
	name = 'Filedata1',
	filename = 'T:\filedata1.ndf',
	size =5mb
)to filegroup Test1FG1

alter database [SmallWorks] add file(
	name = 'Filedata2',
	filename = 'T:\filedata2.ndf',
	size = 5mb
) to filegroup Test1FG1


-- Câu 5: Dùng T-SQL tạo thêm một một file thứ cấp  filedat3.ndf  dung lượng 3MB trong 
--filegroup Test1FG1. Sau đó sửa kích thước tập tin này lên 5MB. Dùng SSMS xem 
-kết quả. Dùng T-SQL xóa file thứ cấp filedat3.ndf. Dùng SSMS xem kết  quả

alter database [SmallWorks] add file(
	name ='Filedata3',
	filename ='T:\filedata3.ndf',
	size =3mb
)to filegroup Test1FG1
--chinh sửa size:
alter database [SmallWorks]
modify file (name ='Filedata3',size =5mb)
--xóa file:
alter database [SmallWorks] remove file Filedata3
alter database [SmallWorks] remove file Filedata2
alter database [SmallWorks] remove file Filedata1

--Câu 6: Xóa  filegroup  Test1FG1?  Bạn  có  xóa  được  không?  Nếu  không  giải  thích?  Muốn  xóa 
--được bạn phải làm  gì?

-- xóa group:
alter database [SmallWorks] remove file Test1FG1
-- muốn xóa group phải trống nên phải xóa nội dung của group

alter database [SmallWorks] remove file Filedata3
alter database [SmallWorks] remove file Filedata2
alter database [SmallWorks] remove file Filedata1

--xóa: 
alter database [SmallWorks] remove file Test1FG1

--Câu 7: Xem  lại  thuộc  tính  (properties)  của  CSDL  SmallWorks  bằng  cửa  sổ  thuộc  tính 
--properties  và  bằng  thủ  tục  hệ  thống  sp_helpDb,  sp_spaceUsed,  sp_helpFile. 
--Quan sát và cho biết các trang thể hiện thông tin  gì?.

sp_helpDB [SmallWorks] -- hiển thị file của cơ sở dữ liệu
sp_spaceUsed [SmallWorks]
sp_helpFile Filedata1

--Câu 8: Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó 
--đóng  cửa  sổ  properties.  Quan  sát  màu  sắc  của  CSDL.  Dùng  lệnh  T-SQL  gỡ  bỏ
--thuộc  tính  ReadOnly  và  đặt  thuộc  tính  cho  phép  nhiều  người  sử  dụng  CSDL
--SmallWorks.
alter database [SmallWorks] 
set read_only

alter database [SmallWorks]
set read_write

--Câu 9: Trong CSDL SmallWorks, tạo 2 bảng mới theo cấu trúc như  sau:
use [SmallWorks]
create table dbo.person
(
	PersonID int not null,
	FirstName varchar (50),
	MiddleName varchar (50),
	LastName varchar(50),
	EmailAddress nvarchar(50) null
) on SWUserData1

--sửa dữ liệu cho cột:
use [SmallWorks]
alter table [dbo].[person] alter column MiddleName varchar(50) null

create table dbo.Product
(
	ProductID int not null,
	ProductName varchar(75) not null,
	ProductNumber nvarchar(25) not null,
	StandarCost money not null,
	ListPrice money not null
) on SWUserData2

--Câu 10: chèn dữ liệu 2 bảng trên , lấy dữ liệu từ bảng Person và bảng Product trong [AdventureWorks2008R2]
use [AdventureWorks2008R2] 
insert into [SmallWorks]..person(PersonID, FirstName, MiddleName, LastName, EmailAddress)
select p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, e.EmailAddress
from Person.Person as p inner join Person.EmailAddress as e -- join 2 bảng lấy địa chỉ email
on p.BusinessEntityID = e.BusinessEntityID

--insert nhiều lần nên số lượng rows tăng lên
use [SmallWorks] 
select * from person

--Câu 11:  Dùng SSMS, Detach cơ sở dữ liệu SmallWorks ra khỏi phiên làm việc của  SQL
use master
go
sp_detach_db 'SmallWorks'
go

--Câu 12: Dùng SSMS, Attach cơ sở dữ liệu SmallWorks vào  SQL
sp_attach_db 'SmallWorks',
'T:\LyHoangNghiem\SmallWorks.mdf',
'T:\LyHoangNghiem\SmallWorks_log.ldf'
go
use SmallWorks