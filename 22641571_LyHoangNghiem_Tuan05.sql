-- BAI TAP TUAN 5
  --1. viết một thủ tục tính tổng tiền thu (TtalDue) của mỗi khách hàng trong
  -- một tháng bất kỳ của 1 năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím
  -- thông tin gồm: CustomerID, SumOfTotalDua  = sum(TotalDua)
use AdventureWorks2008R2
go
create proc Cau1 @thang int, @nam int
as
 begin 
    select CustomerID, sum(TotalDue) as SumOfTotalDua
	from Sales.SalesOrderHeader a
	where MONTH(a.OrderDate) = @thang  and YEAR(OrderDate) = @nam
	group by CustomerID
 end
go
exec Cau_1 7 ,2005

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
go 
create proc Cau2 @SalesPerson Int, @SalesYTD Money output
as
  begin 
   select @SalesYTD = SalesYTD
   from Sales.SalesPerson
   where BusinessEntityID = @SalesPerson
  end
go

declare @doanhthu money
exec Cau_2 274, @doanhthu out
select @doanhthu as DoanhThu

-- cau3: Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice). 
go
create proc Cau3 @MaxPrice money
as
 begin
 select ProductID, ListPrice
 from Production.Product
 where ListPrice <= @MaxPrice
 end
go
exec Cau_3 700

-- cau 4: Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới 
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--SumOfSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01 
go
create proc NewBonuss @SalesPerson int
as
 begin 
 select SalesPersonID, (Bonus + sum(SubTotal)*0.01) as  NewBonus, sum(SubTotal) SumOfSubTotal 
 from Sales.SalesPerson a inner join Sales.SalesOrderHeader b
 on a.BusinessEntityID = b.SalesPersonID
 where @SalesPerson = BusinessEntityID
 group by SalesPersonID, Bonus
 end
go

select SalesPersonID
from Sales.SalesPerson A INNER JOIN Sales.SalesOrderHeader B
on A.BusinessEntityID = B.SalesPersonID

exec NewBonuss 283

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query) 

go 
create  proc Cau5 @nam int
as
  begin
  select TOP 1c.ProductCategoryID, c.Name, sum(OD.OrderQty) as SumOfQty
  from Production.ProductCategory c Inner join Production.ProductSubcategory SC
  on c.ProductCategoryID = SC.ProductCategoryID
      inner join Production.Product P  on SC.ProductSubcategoryID = P.ProductSubcategoryID
	  inner join Sales.SalesOrderDetail OD on P.ProductID = OD.ProductID
  where od.SalesOrderID = (select top 1 SalesOrderID from  Sales.SalesOrderDetail where YEAR(ModifiedDate) = @nam order by OrderQty desc)
  group by c.ProductCategoryID, c.Name
  end
 go

 exec Cau_5 2006




--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ tục.
go
create proc  TongThu @maNhanVien int, @tongTriGiaHD money output
as
 begin
  set @tongTriGiaHD = 0
   select @tongTriGiaHD = sum(OH.SubTotal)
   from Sales.SalesPerson P inner join Sales.SalesOrderHeader OH
    on P.BusinessEntityID = OH.SalesPersonID
    where p.BusinessEntityID = @maNhanVien
	group by p.BusinessEntityID
   if @tongTriGiaHD > 0 return 0
   else return 1
 end
go
declare @TongThu money, @triTraVe int
exec @triTraVe = TongThu 277, @TongThu out

select @TongThu as [TONG TRI GIA], @triTraVe as [Tri Tra Ve]
if @triTraVe = 0
  print'Thu tuc thanh cong'
  else print 'Thu tuc khong thanh cong'
go





--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho

go
create proc cau7 @nam int
as
 begin 
  select top 1 p.FirstName + ' '+ p.MiddleName+' '+p.LastName as ten, SUM(oh.TotalDue) as [SO TIEN]
  from sales.SalesOrderHeader oh inner join sales.Customer c
    on oh.CustomerID = c.CustomerID inner join sales.Store s
	on c.StoreID = s.BusinessEntityID inner join Person.Person p
	on c.PersonID = p.BusinessEntityID
  where YEAR(oh.OrderDate) = @nam
  group by c.CustomerID, p.FirstName,p.MiddleName, p.LastName
  order by [SO TIEN] desc
 end
go
 exec cau7 2007


--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa ngoại.
use AdventureWorks2008R2
go
 CREATE PROCEDURE Sp_InsertProduct
    @ProductName NVARCHAR(50),
    @ProductNumber NVARCHAR(25),
    @MakeFlag BIT,
    @FinishedGoodsFlag BIT,
    @Color NVARCHAR(15),
    @SafetyStockLevel SMALLINT,
    @ReorderPoint SMALLINT,
    @StandardCost MONEY,
    @ListPrice MONEY,
    @Size NVARCHAR(5),
    @SizeUnitMeasureCode NVARCHAR(3),
    @WeightUnitMeasureCode NVARCHAR(3),
    @Weight DECIMAL(8, 2),
    @DaysToManufacture INT,
    @ProductLine NCHAR(2),
    @Class NCHAR(2),
    @Style NCHAR(2),
    @ProductSubcategoryID INT,
    @ProductModelID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Production.Product (
        Name,
        ProductNumber,
        MakeFlag,
        FinishedGoodsFlag,
        Color,
        SafetyStockLevel,
        ReorderPoint,
        StandardCost,
        ListPrice,
        Size,
        SizeUnitMeasureCode,
        WeightUnitMeasureCode,
        Weight,
        DaysToManufacture,
        ProductLine,
        Class,
        Style,
        ProductSubcategoryID,
        ProductModelID
    )
    VALUES (
        @ProductName,
        @ProductNumber,
        @MakeFlag,
        @FinishedGoodsFlag,
        @Color,
        @SafetyStockLevel,
        @ReorderPoint,
        @StandardCost,
        @ListPrice,
        @Size,
        @SizeUnitMeasureCode,
        @WeightUnitMeasureCode,
        @Weight,
        @DaysToManufacture,
        @ProductLine,
        @Class,
        @Style,
        @ProductSubcategoryID,
        @ProductModelID
    );
END;
go



--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong 
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong 
--Sales.SalesOrderDetail.
go
create proc xoaHD @SalesOrderID int
as
 begin
  delete from Sales.SalesOrderHeader
  where SalesOrderID = @SalesOrderID
 end
 go
 select *from Sales.SalesOrderHeader


--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
--này.
go
create proc capNhat @ProductId int
as
 begin
  if @ProductId is not null
  update Production.Product
  set ListPrice = (ListPrice+ListPrice*0.1) where ProductID = @ProductId
  else
   print'San pham khong ton tai'
 end
go
select*from Production.Product where ProductID = 735