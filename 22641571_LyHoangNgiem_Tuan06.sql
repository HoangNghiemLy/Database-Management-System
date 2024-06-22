---- Tuần  06: 
-- Table Valued Functions:





--4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
go
create function SumOfOrder (@thang int, @nam int)
returns table 
as 
return(
	select oh.SalesOrderID, OrderDate, sum (OrderQty * UnitPrice) as SubTotal
	from Sales.SalesOrderDetail od inner join Sales.SalesOrderHeader oh
	on od.SalesOrderID = oh.SalesOrderID
	where datepart (MM,OrderDate) = @thang and DATEPART(YY, OrderDate) = @nam 
	group by oh.SalesOrderID, OrderDate
	having sum(OrderQty*UnitPrice) > 70000
)
go

--xem dữ liệu

select oh.SalesOrderID, OrderDate, sum (OrderQty * UnitPrice) as SubTotal
	from Sales.SalesOrderDetail od inner join Sales.SalesOrderHeader oh
	on od.SalesOrderID = oh.SalesOrderID
--	where datepart (MM,OrderDate) = @thang and DATEPART(YY, OrderDate) = @nam 
	group by oh.SalesOrderID, OrderDate
	having sum(OrderQty*UnitPrice) > 70000

--cách gọi hàm
select * from SumOfOrder(8,2005)

select *from SumOfOrder(4,2005) --ko có dữ liệu 

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
go 
CREATE FUNCTION NewBonus()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        SalesPersonID,
        (Bonus + SUM(TotalDue) * 0.01) AS NewBonus,
        SUM(TotalDue) AS SumOfSubTotal
    FROM 
        Sales.SalesOrderHeader AS SOH
    INNER JOIN 
        Sales.SalesPerson AS SP ON SOH.SalesPersonID = SP.BusinessEntityID
    GROUP BY 
        SalesPersonID, Bonus
);
go

select * from dbo.NewBonus()


--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])

go 
create function SumOfProduct (@MANCC int)
returns table 
as 
return (
	select pod.ProductID, sum(ReceivedQty) as SumOfProduct,sum(SubTotal) as SumOfSubTotal
	from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader poh 
	on poh.VendorID = v.BusinessEntityID
	join Purchasing.PurchaseOrderDetail pod on pod.PurchaseOrderID = poh.PurchaseOrderID
	where v.BusinessEntityID = @MANCC
	group by pod.ProductID
)
go

select *from SumOfProduct(1562)	


--7)Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case.. When … Then …
--(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader])gocreate function Discount_Func( @SalesOrderID int )returns table as return (	select SalesOrderID, SubTotal,	case 		when SubTotal < 1000 then 0		when SubTotal >= 1000 and SubTotal < 5000 then 0.05*SubTotal		when SubTotal >= 5000 and SubTotal < 10000 then 0.10 * SubTotal		else 0.15 * SubTotal	end as Discount 	from Sales.SalesOrderHeader 	where SalesOrderID = @SalesOrderID)go--xem dữ liệuselect *from Sales.SalesOrderHeader--chạy hàmselect * from Discount_Func(43659)--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với 
--Total=Sum([SubTotal])
-- Multi-statement Table Valued Functions:gocreate function TotalOfEmp (@MonthOrder int , @YearOrder int )returns table asreturn (		select soh.SalesPersonID, sum(soh.TotalDue) as Total 	from Sales.SalesOrderHeader as soh	where MONTH(soh.OrderDate) = @MonthOrder	and YEAR(soh.OrderDate) = @YearOrder 	group by soh.SalesPersonID		)go select * from Sales.SalesOrderHeaderselect * from TotalOfEmp(8,2005)

--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
-- Định nghĩa hàm NewBonus
go
CREATE FUNCTION NewBonus_Mul()
RETURNS @NewBonusTable TABLE (
    SalesPersonID INT,
    NewBonus MONEY,
    SumOfSubTotal MONEY
)
AS
BEGIN
    INSERT INTO @NewBonusTable (SalesPersonID, NewBonus, SumOfSubTotal)
     SELECT 
        SalesPersonID,
        (Bonus + SUM(TotalDue) * 0.01) AS NewBonus,
        SUM(TotalDue) AS SumOfSubTotal
    FROM 
        Sales.SalesOrderHeader AS SOH
    INNER JOIN 
        Sales.SalesPerson AS SP ON SOH.SalesPersonID = SP.BusinessEntityID
    GROUP BY 
        SalesPersonID, Bonus
	return 
END;
go 

select * from NewBonus_Mul()

--6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
--ProductID, SumOfProduct, SumOfSubTotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])
-- Định nghĩa hàm SumOfProduct
go
CREATE FUNCTION SumOfProduct_Mul(@MaNCC INT)
RETURNS @ProductSummary TABLE (
    ProductID INT,
    SumOfQty INT,
    SumOfSubTotal MONEY
)
AS
BEGIN
    INSERT INTO @ProductSummary (ProductID, SumOfQty, SumOfSubTotal)
	select pod.ProductID, sum(ReceivedQty) as SumOfProduct,sum(SubTotal) as SumOfSubTotal
	from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader poh 
	on poh.VendorID = v.BusinessEntityID
	join Purchasing.PurchaseOrderDetail pod on pod.PurchaseOrderID = poh.PurchaseOrderID
	where v.BusinessEntityID = @MANCC
	group by pod.ProductID
	return
end
go

select * from SumOfProduct_Mul(1562)

--7)Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
--thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case.. When … Then …
--(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader])

go
-- Định nghĩa hàm Discount_Func
CREATE FUNCTION Discount_Func_Mul()
RETURNS @DiscountTable TABLE (
    SalesOrderID INT,
    SubTotal MONEY,
    Discount MONEY
)
AS
BEGIN
    INSERT INTO @DiscountTable (SalesOrderID, SubTotal, Discount)
	select SalesOrderID, SubTotal,	case 		when SubTotal < 1000 then 0		when SubTotal >= 1000 and SubTotal < 5000 then 0.05*SubTotal		when SubTotal >= 5000 and SubTotal < 10000 then 0.10 * SubTotal		else 0.15 * SubTotal	end as Discount 	from Sales.SalesOrderHeader 	return 
end
go

select * from Discount_Func_Mul()

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với 
--Total=Sum([SubTotal])
-- Multi-statement Table Valued Functions:

go
create function TotalOfEmp_Mul(@MonthOrder int, @YearOrder int)
returns @Emtotal table(
	SalesPersonID int,
	Total money
)
as
begin 
	insert into @Emtotal(SalesPersonID, Total)
	select soh.SalesPersonID, sum(soh.TotalDue) as Total 	from Sales.SalesOrderHeader as soh	where MONTH(soh.OrderDate) = @MonthOrder	and YEAR(soh.OrderDate) = @YearOrder 	group by soh.SalesPersonID
	return 
	end
go

select * from TotalOfEmp_Mul(8,2005)


--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham 
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm 
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết 
--quả là bảng lương của nhân viên đó.
--Ví dụ thực thi hàm: select * from SalaryOfEmp(288)

--Kết quả là:
-- Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân 
--viên
--Ví dụ: thực thi hàm select * from SalaryOfEmp(Null)
--Kết quả là 316 record
--(Dữ liệu lấy từ 2 bảng [HumanResources].[EmployeePayHistory] và 
--[Person].[Person] )
go
CREATE FUNCTION SalaryOfEmp(@MaNV INT)
RETURNS TABLE
AS
RETURN
(
    SELECT eph.BusinessEntityID, p.FirstName AS FName, p.LastName AS LName, eph.Rate AS Salary
    FROM HumanResources.EmployeePayHistory eph
    INNER JOIN Person.Person p ON eph.BusinessEntityID = p.BusinessEntityID
    WHERE @MaNV IS NULL OR eph.BusinessEntityID = @MaNV
)
go

select *from SalaryOfEmp(288)

select * from SalaryOfEmp(NULL)