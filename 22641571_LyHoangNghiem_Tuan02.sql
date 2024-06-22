--I) Câu lệnh SELECT sử dụng các hàm thống kê với các mệnh đề Group by và
--Having:
--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
--SubTotal =SUM(OrderQty*UnitPrice).
SELECT h.SalesOrderID, h.Orderdate, SUM(OrderQty*UnitPrice) as SubTotal
FROM Sales.SalesOrderHeader as h join Sales.SalesOrderDetail as d on h.SalesOrderID= d.SalesOrderID
where month(Orderdate) = 6 and year(Orderdate) =  2008
Group by h.SalesOrderID, h.Orderdate
having SUM(OrderQty*UnitPrice)> 70000
--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
SELECT t.TerritoryID, count(Distinct c.CustomerID) as CountOfCust, SUM(OrderQty*UnitPrice) as SubTotal
FROM Sales.SalesTerritory as t join Sales.Customer as c on t.TerritoryID = c.TerritoryID
join Sales.SalesOrderHeader as h on c.CustomerID = h.CustomerID
join Sales.SalesOrderDetail as d on h.SalesOrderID = d.SalesOrderID
where t.CountryRegionCode = 'US'
Group by t.TerritoryID
--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
SELECT h.SalesOrderID, CarrierTrackingNumber, SUM(OrderQty*UnitPrice) as SubTotal
FROM Sales.SalesOrderHeader as h join Sales.SalesOrderDetail as d on h.SalesOrderID= d.SalesOrderID
where LEFT (CarrierTrackingNumber, 3) = '4BD'
Group by h.SalesOrderID, CarrierTrackingNumber
--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
--trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
SELECT P.ProductID, P.Name, AVG(d.OrderQty) as AverageOfQty
FROM Production.Product as P join Sales.SalesOrderDetail as d on P.ProductID = d.ProductID
where d.UnitPrice < 25
Group by P.ProductID, P.Name
having AVG(d.OrderQty) > 5 
--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
--JobTitle,CountOfPerson=Count(*)
SELECT JobTitle, COUNT(*) as CountOfPerson
FROM HumanResources.Employee
Group by JobTitle
having COUNT(*) > 20
--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
--[Purchasing].[PurchaseOrderDetail])
SELECT v.BusinessEntityID,  v.Name as Vendor_Name, vd.ProductID, SUM(vd.OrderQty) as SumOfQty,SUM(vd.OrderQty*vd.UnitPrice) as SubTotal 
FROM Purchasing.Vendor as v join Purchasing.PurchaseOrderHeader as vh on v.BusinessEntityID = vh.VendorID
join Purchasing.PurchaseOrderDetail as vd on vh.PurchaseOrderID = vd.PurchaseOrderID
where v.Name like '%Bicycles'
Group by v.BusinessEntityID, v.Name, vd.ProductID
having SUM(vd.OrderQty*vd.UnitPrice) > 800000
--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal
SELECT P.ProductID, P.Name as Product_Name, COUNT(Distinct d.SalesOrderID) as CountOfOrderID,SUM(d.OrderQty*d.UnitPrice) as SubTotal
FROM Production.Product as P join Sales.SalesOrderDetail as d on P.ProductID
join Sales.SalesOrderHeader as h on d.SalesOrderID = h.SalesOrderID
where year (h.OrderDate) = 2008 and DATEPART(quarter, h.OrderDate) = 1
group by P.ProductID,P.Name
having COUNT(Distinct d.SalesOrderID) > 500 and SUM(d.OrderQty*d.UnitPrice) >10000
--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders).
--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)
--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders).
SELECT c.CustomerID as PersonID, CONCAT(FirstName, ' ', LastName) as FullName, COUNT(h.SalesOrderID) as CountOfOrders
FROM Sales.Customer c join Person.Person p on c.PersonID = p.BusinessEntityID 
join Sales.SalesOrderHeader h on c.CustomerID = h.CustomerID
where year(h.OrderDate) between 2007 and 2008
group by c.CustomerID, FirstName, LastName
having COUNT(h.SalesOrderID) > 25

--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
--Sales.SalesOrderDetail và Production.Product)
SELECT p.ProductID, p.Name, year(OrderDate) as Year, SUM(OrderQty) as CountOfOrderQty
FROM Production.Product p join Sales.SalesOrderDetail d on p.ProductID = d.ProductID
join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
where p.Name like 'Bike%' or p.Name like 'Sport%'
group by p.ProductID, p.Name, year(OrderDate)
having SUM(OrderQty) > 500

--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
SELECT d.DepartmentID, d.Name as DepartmentName, AVG(eh.Rate) as AvgofRate
FROM HumanResources.Department d join HumanResources.EmployeeDepartmentHistory edh on d.DepartmentID = edh.DepartmentID
join HumanResources.EmployeePayHistory eh on edh.BusinessEntityID = eh.BusinessEntityID
group by d.DepartmentID, d.Name
having AVG(eh.Rate) > 30

--II) Subquery
--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
--trên 100 đơn đặt hàng trong tháng 7 năm 2008
select ProductID, Name
from Production.Product
where ProductID in (select ProductID
					from  Sales.SalesOrderDetail d join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
					where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
					group by  ProductID
					having COUNT(*)>100)
---
select ProductID, Name
from Production.Product p 
where  exists (select ProductID
					from  Sales.SalesOrderDetail d join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
					where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008 and ProductID=p.ProductID
					group by  ProductID
					having COUNT(*)>100)

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
--trong tháng 7/2008
select p.ProductID, Name
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
	                      join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where  MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
group by p.ProductID, Name
having COUNT(*)>=all( select COUNT(*)
					  from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
	                  where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
					  group by ProductID
					  )
---cau 3
select [CustomerID], count(*)
from [Sales].[SalesOrderHeader]
group by [CustomerID]
having count(*)>=all(	select count(*)
						from [Sales].[SalesOrderHeader]
						group by [CustomerID])

---câu 3
select [CustomerID], count(*)
from [Sales].[SalesOrderHeader]
group by [CustomerID]
having count(*)>=all(	select count(*)
						from [Sales].[SalesOrderHeader]
						group by [CustomerID]
					)


--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder
select [CustomerID], count(*)
from [Sales].[SalesOrderHeader]
group by [CustomerID]
having count(*)>=all(	select count(*)
						from [Sales].[SalesOrderHeader]
						group by [CustomerID]
					)


select 	c.CustomerID, CountofOrder=COUNT(*)
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
group by c.CustomerID
having COUNT(*)>=all(select COUNT(*)
					 from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
					 group by c.CustomerID)	

--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
--bảng Production.Product và Production.ProductModel)
select * from  Production.Product
where ProductModelID in (
				select ProductModelID from Production.ProductModel 
				where name like 'Long-Sleeve Logo Jersey')


select ProductID, Name
from Production.Product p
where exists (select ProductModelID 
						 from Production.ProductModel
						 where Name like 'Long-Sleeve Logo Jersey%' and ProductModelID=p.ProductModelID)



---11-
--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.
select p.ProductModelID, m.Name, max(ListPrice)
from Production.ProductModel m join Production.Product p on m.ProductModelID=p.ProductModelID
group by p.ProductModelID, m.Name
having max(ListPrice)>=all(select AVG(ListPrice)
							from Production.ProductModel m join Production.Product p on m.ProductModelID=p.ProductModelID
							)

--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)
select ProductID, Name
from Production.Product 
where ProductID in (select ProductID 
					from Sales.SalesOrderDetail
					group by ProductID
					having SUM(OrderQty)>5000)
select ProductID, Name
from Production.Product p
where exists (select ProductID 
					from Sales.SalesOrderDetail
					where ProductID=p.ProductID
					group by ProductID
					having SUM(OrderQty)>5000)

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail
select distinct ProductID, UnitPrice
from Sales.SalesOrderDetail
where UnitPrice>=all (select distinct UnitPrice
					 from Sales.SalesOrderDetail)

--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join.



select P.productID, Name
from Production.Product p left join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
where d.ProductID is null

select productID, Name
from Production.Product
where productID not in (select productID 
						from Sales.SalesOrderDetail)

select productID, Name
from Production.Product p
where not exists (select productID 
				  from Sales.SalesOrderDetail
				  where p.ProductID=ProductID)



SELECT ProductID
FROM Products
WHERE ProductID NOT IN (SELECT ProductID FROM Orders);

SELECT ProductID
FROM Products P
WHERE NOT EXISTS (SELECT 1 FROM Orders O WHERE O.ProductID = P.ProductID);

SELECT P.ProductID
FROM Production.Product
LEFT JOIN Orders O ON P.ProductID = O.ProductID
WHERE O.ProductID IS NULL;


--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
--HumanResources.Employees và Sales.SalesOrdersHeader)
SELECT E.EmployeeID, E.FirstName, E.LastName
FROM HumanResources.Employees as E LEFT JOIN Sales.SalesOrdersHeader as D ON E.EmployeeID = D.EmployeeID
WHERE D.OrderDate IS NULL OR D.OrderDate  




select [BusinessEntityID] as EmployeeID, FirstName, LastName
from [Person].[Person]
where [BusinessEntityID]  in (select [SalesPersonID]
								 from [Sales].[SalesOrderHeader]
								 where [OrderDate]>'2008-5-1')


--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
select [CustomerID]
from [Sales].[SalesOrderHeader]
where [CustomerID] in (select [CustomerID]
					   from [Sales].[SalesOrderHeader]
					   where year([OrderDate])=2007 )  
	and [CustomerID] not in (select [CustomerID]
					   from [Sales].[SalesOrderHeader]
					   where year([OrderDate])=2008)
select [name]
from [Sales].[SalesOrderHeader]
where [name] in (select [name]
					   from [Sales].[SalesOrderHeader]
					   where year([OrderDate])=2007 )  
	and [name] not in (select [name]
					   from [Sales].[SalesOrderHeader]
					   where year([OrderDate])=2008)
