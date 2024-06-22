--Tuần 04 
--Batch
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm 
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
--hàng”
go 
use AdventureWorks2008R2
go
declare @tongsoHD int, @masp int
set @masp = 778 
select @tongsoHD = count(SalesOrderID)
from Sales.SalesOrderDetail
where @masp = ProductID
if (@tongsoHD > 500)
	print concat('San pham 778 co nhieu don dat hang ',@tongsohd)
else
	print concat('San pham 778 co it don dat hang ',@tongsohd)





--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” 
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào 
--trong năm 2008”
go 
use AdventureWorks2008R2
declare @nam int, @makh int, @n int 
set @nam = 2008
set @makh = 12136
select @n = count(*)
from sales.SalesOrderHeader
where Year(OrderDate) =@nam and CustomerID=@makh
if @n>0
	print concat('khach hang co ',@n,' hoa don trong nam ',@nam)
else 
	print concat('khach hang  ',@n,' ko co  hoa don trong nam ',@nam)



select *
from Sales.SalesOrderHeader

--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như sau:
-- Những hóa đơn có SubTotal<100000 thì không giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal

go 
use AdventureWorks2008R2
select SalesOrderID, sum(LineTotal) as SubTotal, sum(LineTotal)*(
case 
	when SUM(LineTotal)<10000 then 0
	when Sum(LineTotal)<12000 then 0.05
	when sum(LineTotal)<15000 then 0.10
	else 0.15
end)as Discount
from Sales.SalesOrderDetail
group by Sales.SalesOrderDetail.SalesOrderID


--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung 
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
--cung cấp sản phẩm 4 với số lượng là 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

go
use AdventureWorks2008R2
declare @mancc int , @masp int , @soluongcc int 
set @mancc = 1580 
set @masp = 1 
select @soluongcc = OnOrderQty
from [Purchasing].[ProductVendor]
where BusinessEntityID = @mancc and ProductID = @masp

if @soluongcc is null 
	print concat('Nha cung cap ',@mancc,' khong cung cap san pham ',@masp)
else 
	print concat('Nha cung cap ',@mancc,' cung cap san pham ',@masp, ' voi so luong ',@soluongcc)





--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.

DECLARE @SumRate MONEY, @MaxRate MONEY;

-- Lấy tổng lương giờ của tất cả nhân viên
SELECT @SumRate = SUM(Rate) 
FROM [HumanResources].[EmployeePayHistory];

-- Lấy lương giờ cao nhất của nhân viên
SELECT @MaxRate = MAX(Rate)
FROM [HumanResources].[EmployeePayHistory];

-- Kiểm tra điều kiện
IF @SumRate < 6000
BEGIN
    -- Cập nhật tăng lương giờ lên 10%
    UPDATE [HumanResources].[EmployeePayHistory]
    SET Rate = Rate * 1.1;

    -- Kiểm tra lại lương giờ cao nhất sau khi cập nhật
    SELECT @MaxRate = MAX(Rate)
    FROM [HumanResources].[EmployeePayHistory];

    -- Dừng nếu lương giờ cao nhất > 150
    IF @MaxRate > 150
        RETURN;  -- Use RETURN to exit the procedure
END;

-- Thông báo kết quả
PRINT 'Tăng lương giờ thành công!';

select Rate
from HumanResources.EmployeePayHistory

---------------------------------
-- câu 5 : 

go
select *
into [HumanResources].[EmployeePayHistory113]
from HumanResources.EmployeePayHistory
go
WHILE (SELECT SUM(rate) FROM
[HumanResources].[EmployeePayHistory])<6000 
BEGIN
	UPDATE [HumanResources].[EmployeePayHistory] 
	SET rate = rate*1.1
	IF (SELECT MAX(rate)FROM
	[HumanResources].[EmployeePayHistory]) > 150 
		BREAK
	ELSE
		CONTINUE
END


select *
from HumanResources.EmployeePayHistory113

select sum(Rate) as sum 
from HumanResources.EmployeePayHistory113