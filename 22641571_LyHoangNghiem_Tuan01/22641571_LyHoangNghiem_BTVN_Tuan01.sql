CREATE DATABASE SmallWorks
on primary 
(
	NAME = 'SmallWorksPrimary',
	FILENAME = 'E:\HỆ QUẢN TRỊ CSDL - BAITAP\22641571_LyHoangNghiem_Tuan01\SmallWorksPrimary.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE	= 50MB
)
LOG ON(
	NAME = 'SmallWorks_log',
	FILENAME = 'E:\HỆ QUẢN TRỊ CSDL - BAITAP\22641571_LyHoangNghiem_Tuan01\SmallWorksPrimary_log.ldf',
	size = 10mb,
	filegrowth = 20%,
	maxsize = 20mb
)

-- 1. Tạo các kiểu dữ liệu người dùng sau:
exec sp_addtype Mota , 'nvarchar(40)', 'null'
exec sp_addtype IDKH, 'char(10)' , 'not null'
exec sp_addtype DT, 'char(12)' , 'null'


-- 2. Tạo các bảng theo cấu trúc sau:
create table SanPham(
	Masp  char(6), 
	TenSp varchar(20),
	NgayNhap Date,
	DVT char(10),
	SoLuongTon int,
	DonGiaNhap money
)

create table HoaDon(
	MaHD Char(10),
	NgayLap Date,
	NgayGiao Date,
	Makh IDKH,
	DienGiai Mota,
)

create table KhachHang(
	MaKH IDKH,
	TenKH Nvarchar(30),
	Diachi Nvarchar(40),
	Dienthoai DT
)

create table ChiTietHD(	
	MaHD Char(10),
	Masp	Char(6),
	Soluong 	int
)

-- 3. Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100).
alter table HoaDon alter column DienGiai Nvarchar(100)
-- 4. Thêm vào bảng SanPham cột TyLeHoaHong float
-- them cot thi kh can chu column
alter table SanPham add TyLeHoaHong float

-- 5. Xóa cột NgayNhap trong bảng SanPham
alter table SanPham drop column [NgayNhap]
-- 6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên


alter table SanPham alter column Masp char(6) not null
alter table HoaDon alter column MaHD char(10) not null


alter table SanPham add constraint maspkc primary key (Masp)
alter table HoaDon add constraint mahdkc primary key (MaHD)
alter table KhachHang add constraint makhkc primary key (MaKH)

alter table ChiTietHD add constraint maspfk foreign key (Masp) references SanPham(Masp)
alter table ChiTietHD add constraint mahdfk foreign key (MaHD) references HoaDon(MaHD)
alter table HoaDon add constraint makhfk foreign key (Makh) references KhachHang(MaKH)

-- 7. Thêm vào bảng HoaDon các ràng buộc sau:
alter table HoaDon add constraint kkk check (NgayGiao >= NgayLap)

ALTER TABLE HoaDon
ADD CONSTRAINT CHK_MaHD CHECK (
     LEFT(MaHD, 2) LIKE '[A-Z][A-Z]' AND
     SUBSTRING(MaHD, 3, 4) LIKE '[0-9][0-9][0-9][0-9]'
)

ALTER TABLE HoaDon drop constraint CHK_MaHD


-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
alter table HoaDon add constraint NgayDF default Getdate() for NgayLap

-- 8. Thêm vào bảng Sản phẩm các ràng buộc sau:
-- SoLuongTon chỉ nhập từ 0 đến 500
alter table SanPham add constraint SoLuongSize check (SoLuongTon>=0 and SoLuongTon<=500)
-- DonGiaNhap lớn hơn 0
alter table SanPham add constraint DonGiaCheck check (DonGiaNhap > 0)
-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
alter table SanPham add constraint DVTCHECK check (DVT in ('KG', 'Thùng', 'Hộp', 'Cái'))
-- 9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng buộc của mỗi Table

insert into SanPham(Masp,TenSp,DVT,SoLuongTon,DonGiaNhap,[TyLeHoaHong]) 
values
	('SP001','May lanh','Cái',50,10000000,40.5),
	('SP002','May giat','Cái',51,1200000,50.5),
	('SP003','Tu lanh','Cái',52,15000000,30.2),
	('SP004','May nuoc nong','Cái',53,8000000,35.5),
	('SP005','Lo vi song','Cái',54,5000000,40.2),
	('SP006','Laptop ','Hộp',55,20000000,40),
	('SP007','The nho 8GB','Cái',56,100000,56.5);

insert into KhachHang(MaKH, TenKH, Diachi, Dienthoai) 
values
	('KH001', 'Nguyễn Văn A', 'TPHCM', '0985491556'),
	('KH002', 'Trần Chu Huyền', 'Đà Nẵng', '098795568'),
	('KH003', 'Lâm Văn Chú Bé', 'Hà Nội', '09821211658'),
	('KH004', 'Nguyễn Thị Ba', 'Gia Lai', '0389189851'),
	('KH005', 'Lê Văn Tú', 'Kon Tum', '023595292616');

insert  into HoaDon(MaHD,NgayGiao,Makh,DienGiai)
values 
	('AZ01', '2024-2-3', 'KH001', null),
	('AZ02', '2024-5-4', 'KH002', null),
	('AZ03', '2024-7-2', 'KH003', null),
	('AZ04', '2024-9-7', 'KH004', null),
	('AZ05', '2024-10-12','KH005',null);

insert into ChiTietHD(MaHD ,Masp, Soluong)
values
	('AZ01', 'SP002' , 40),
	('AZ02', 'SP003' , 35),
	('AZ03', 'SP004' , 30),
	('AZ04', 'SP005' , 25);


--10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu 
--vẫn muốn xóa thì phải dùng cách nào?
DELETE from HoaDon  where MaHD = 'AZ02'
-- không thể xóa được vi bản thân nó đang liên kết với các table khác nói cách khác là nó có khóa ngoại

--11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và 
--MaHD=’1234567890’. Có nhập được không? Tại sao?

-- --Không được vì có ràng buộc mahd 

--12. Đổi tên CSDL Sales thành BanHang
ALTER DATABASE SmallWorks MODIFY Name= BanHang

--13. Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao 
--chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao 
--chép, bạn thực hiện Attach CSDL vào lại SQL.

--14. Tạo bản BackUp cho CSDL BanHang
-- NOI LUU TRU BACKUP: C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\
--15. Xóa CSDL BanHang
DROP DATABASE  BanHang
--16. Phục hồi lại CSDL BanHang.