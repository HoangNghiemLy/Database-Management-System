--cau 1
create table M_Department
(
DepartmentID int not null primary key, 
Name nvarchar(50),
GroupName nvarchar(50)
)
create table M_Employees 
(
EmployeeID int not null primary key, 
Firstname nvarchar(50),
MiddleName nvarchar(50), 
LastName nvarchar(50),
DepartmentID int foreign key references M_Department(DepartmentID)
)


create view EmpDepart_View
as
	select EmployeeID, FirstName, MiddleName, LastName, me.DepartmentID, Name, GroupName
	from [dbo].[M_Department] md join [dbo].[M_Employees] me on md.DepartmentID = me.DepartmentID

create trigger InsteadOf_Trigger
on [dbo].[EmpDepart_View]
instead of insert
as
begin
	insert into M_Department(DepartmentID, Name, GroupName)
	select i.DepartmentID, i.Name, i.GroupName
	from inserted i
	where not exists (select 1 from M_Department where DepartmentID = i.DepartmentID)

	insert into M_Employees(EmployeeID, Firstname, MiddleName, LastName, DepartmentID)
	select EmployeeID, Firstname, MiddleName, LastName, DepartmentID
	from inserted i
end






--cau 2
create table MCustomer
(
CustomerID int not null primary key, 
CustPriority int
)

create table MSalesOrders 
(
SalesOrderID int not null primary key, 
OrderDate date,
SubTotal money,
CustomerID int foreign key references MCustomer(CustomerID) )

insert into MCustomer (CustomerID, CustPriority)
select CustomerID, NULL
from [Sales].[Customer]
where CustomerID>30100 and CustomerID < 30118

insert into MSalesOrders (SalesOrderID,OrderDate,SubTotal, CustomerID)
select [SalesOrderID], [OrderDate], [SubTotal], [CustomerID]
from Sales.SalesOrderHeader
where [CustomerID] in (select CustomerID from MCustomer)
create view [dbo].[EmpDepart_View]
as
	select MC.CustomerID, CustPriority, SalesOrderID, OrderDate, SubTotal
	from MCustomer MC JOIN MSalesOrders MS on MC.CustomerID = MS.CustomerID



select * from [dbo].[EmpDepart_View]

alter Trigger huycubade
on [dbo].[EmpDepart_View]
instead of insert, delete
as
begin
	if exists (select 1 from inserted)
	begin
		insert into MCustomer(CustomerID, CustPriority)
		select i.CustomerID, null
		from inserted i
		where not exists (select 1 from MCustomer where [CustomerID] = i.CustomerID)
		
		insert into [dbo].[MSalesOrders]([SalesOrderID], [OrderDate], [SubTotal], [CustomerID])
		select [SalesOrderID], [OrderDate], [SubTotal], [CustomerID]
		from inserted i
	

		declare @manv int, @total float
		select @manv = i.CustomerID
		from inserted i

		select @total = sum(MS.SubTotal)
		from MCustomer MC JOIN MSalesOrders MS on MC.CustomerID = MS.CustomerID
		where MC.CustomerID = @manv
		group by MC.CustomerID
		 

		update [dbo].[MCustomer]
		set [CustPriority] = case 
			when @total < 10000 then 3
			when @total >= 10000 and @total < 50000 then 2
			when @total >= 50000 then 1
		end
		where [CustomerID] = @manv
		end
	else if exists (select 1 from deleted)
	begin
	-- xoa
		declare @salseodid int
		declare @ctmid int

		select @salseodid = d.SalesOrderID , @ctmid = d.CustomerID
		from deleted d
		
		delete from [dbo].[MSalesOrders]
		where [SalesOrderID] = @salseodid   and [CustomerID] = @ctmid

		if not exists (select 1 from  MCustomer MC JOIN MSalesOrders MS on MC.CustomerID = MS.CustomerID where [SalesOrderID] = @salseodid   and MC.[CustomerID] = @ctmid)
		begin
			delete from MCustomer
			where [CustomerID] = @ctmid
		end

		
		-- cap nhat lai
		declare @total1 float
		select @total = sum(MS.SubTotal)
		from MCustomer MC JOIN MSalesOrders MS on MC.CustomerID = MS.CustomerID
		where MC.CustomerID = @ctmid
		group by MC.CustomerID

		update [dbo].[MCustomer]
		set [CustPriority] = case 
			when @total < 10000 then 3
			when @total >= 10000 and @total < 50000 then 2
			when @total >= 50000 then 1
		end
		where [CustomerID] = @ctmid
	end
end

select * from [dbo].[EmpDepart_View]
select * from [dbo].[MSalesOrders]
insert into [dbo].[EmpDepart_View] ([CustomerID], [SalesOrderID], [OrderDate], [SubTotal])
values(30119, 69, GETDATE(), 15000)

delete from [dbo].[EmpDepart_View]
where [CustomerID] = 30119 and [SalesOrderID] = 69

drop trigger huycubade
--cau 3
create table MDepartment
(
DepartmentID int not null primary key,
Name nvarchar(50),
NumOfEmployee int
)
create table MEmployees
(
EmployeeID int not null,
FirstName nvarchar(50),
MiddleName nvarchar(50), 
LastName nvarchar(50),
DepartmentID int foreign key references MDepartment(DepartmentID), 
constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)

insert into MDepartment([DepartmentID], [Name], [NumOfEmployee])
select [DepartmentID], [Name], NULL
from [HumanResources].[Department]

insert into [dbo].[MEmployees]([EmployeeID], [FirstName], [MiddleName], [LastName], [DepartmentID])
select edh.[BusinessEntityID], p.FirstName, p.MiddleName, p.LastName, edh.DepartmentID
from [HumanResources].[EmployeeDepartmentHistory] edh join [HumanResources].[Employee] e
on edh.BusinessEntityID = e.BusinessEntityID join [Person].[Person] p on p.BusinessEntityID = e.BusinessEntityID

create view view_of_departmant_employee
as
	select md.[DepartmentID], [Name], [NumOfEmployee], [EmployeeID], [FirstName], [MiddleName], [LastName]
	from [dbo].[MDepartment] md join [dbo].[MEmployees] me on md.DepartmentID = me.DepartmentID


select * from [dbo].[MDepartment]
select * from [dbo].[MEmployees]
alter trigger phongBan
on [dbo].[view_of_departmant_employee]
instead of insert
as
begin
	-- trich xuat ma nhan vien va can ho da them
	declare @dpmid int, @maNhanVien int
	select @dpmid = i.[DepartmentID], @maNhanVien = i.[EmployeeID]
	from inserted i
	-- dem so luong nhan vien trong mot phong ban 
	declare @sl int
	select @sl = count(me.[EmployeeID])
	from [dbo].[MDepartment] md join [dbo].[MEmployees] me on md.DepartmentID = me.DepartmentID
	where md.[DepartmentID] = @dpmid
	-- kiem tra so luong nhan vien
	if @sl < 15
	begin
		-- kiem tra co trung ma kh 
		if not exists (select 1 from [dbo].[MDepartment] md join [dbo].[MEmployees] me on md.DepartmentID = me.DepartmentID where md.[DepartmentID] = @dpmid and me.[EmployeeID] = @maNhanVien)
		begin
			insert into [dbo].[MDepartment] ([DepartmentID],[Name])
			select i.[DepartmentID], i.[Name]
			from inserted i
			where not exists (select 1 from [dbo].[MDepartment] where [DepartmentID] = i.[DepartmentID])

			update [dbo].[MDepartment]
			set [NumOfEmployee] = @sl + 1
			where [DepartmentID] = @dpmid

			insert into [dbo].[MEmployees] ([EmployeeID], [FirstName], [MiddleName], [LastName], [DepartmentID])
			select i.[EmployeeID], i.[FirstName], i.[MiddleName], i.LastName, i.DepartmentID
			from inserted i
		end
		else
		begin
			print 'Trung ma !!!'
		end
	end
	else
	begin
		print 'Phong da qua du !!!' 
	end
end


select count(*) from [dbo].[view_of_departmant_employee] where DepartmentID = 2
SELECT * FROM [dbo].[view_of_departmant_employee] where DepartmentID = 2
insert into [dbo].[view_of_departmant_employee] ([DepartmentID], [Name], [NumOfEmployee], [EmployeeID], [FirstName], [MiddleName], [LastName])
values(2, 'Group C', null, 1321, '2','SD','SDD')
drop trigger phongBan
-- cau 4
create trigger check_1
on [Purchasing].[PurchaseOrderHeader]
instead of insert
as 
begin
	declare @CreditRating int, @Puschase int
	select @CreditRating = v.CreditRating
	from inserted i join [Purchasing].[Vendor] v on i.VendorID = v.BusinessEntityID
	where i.VendorID = v.BusinessEntityID

	if @CreditRating = 5
	begin
		print 'Huy giao tac !!!'
	end
	else
	begin
		insert into [Purchasing].[PurchaseOrderHeader] ([PurchaseOrderID],RevisionNumber, Status, 
		EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, 
		Freight, [ModifiedDate])
		select i.PurchaseOrderID ,i.RevisionNumber, i.Status, i.EmployeeID, i.VendorID, i.ShipMethodID, i.OrderDate, i.ShipDate, i.SubTotal , i.TaxAmt, i.Freight, i.ModifiedDate
		from inserted i
		where not exists (select 1 from [Purchasing].[PurchaseOrderHeader] where [PurchaseOrderID] = i.PurchaseOrderID)
	end
end

INSERT INTO Purchasing.PurchaseOrderHeader ([PurchaseOrderID] , RevisionNumber, Status, 
EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, 
Freight, [ModifiedDate]) VALUES (4013,2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55, 3567.564, 1114.8638, GETDATE() )
set IDENTITY_INSERT Purchasing.PurchaseOrderHeader on
select * from [Purchasing].[Vendor]

select * from [Purchasing].[PurchaseOrderHeader] where [PurchaseOrderID]=4013
--cau 5
create view sod_pi
as
	select [SalesOrderID], [SalesOrderDetailID], [CarrierTrackingNumber], [SalesOrderID], [SalesOrderDetailID], [CarrierTrackingNumber], [OrderQty], sod.[ProductID], [SpecialOfferID], [UnitPrice], [UnitPriceDiscount],
	[LineTotal], Quantity
	from [Sales].[SalesOrderDetail] sod join [Production].[Product] p on p.ProductID = sod.ProductID
	join [Production].[ProductInventory] bi on bi.ProductID = p.ProductID

create trigger hyuy
on [Sales].[SalesOrderDetail]
instead of insert 
as
begin
	-- lay ma san pham va so don dat hang khi them
	declare @sumofquantity int,@sanPhamid int, @orderqty int 
	select @sanPhamid = i.ProductID, @orderqty = i.OrderQty
	from inserted i 
	-- lay tong so luong co mat hang do o moi locationid
	select @sumofquantity= sum(Quantity)
	from [Production].[ProductInventory]
	where ProductID = @sanPhamid
	print @orderqty
	print @sumofquantity
	-- so sanh 
	if @sumofquantity > @orderqty
	begin
		insert into Sales.SalesOrderDetail([SalesOrderID], [SalesOrderDetailID], [CarrierTrackingNumber], [OrderQty], [ProductID], [SpecialOfferID], [UnitPrice], [UnitPriceDiscount])
		select i.[SalesOrderID], i.[SalesOrderDetailID], i.[CarrierTrackingNumber], i.[OrderQty], i.[ProductID], i.[SpecialOfferID], i.[UnitPrice], i.[UnitPriceDiscount]
		from inserted i
		where not exists (select 1 from Sales.SalesOrderDetail where [SalesOrderDetailID] = i.SalesOrderDetailID)

		while @orderqty > 0
		begin
			declare @tmp int
			select @tmp = max(Quantity)
			from [Production].[ProductInventory]
			where ProductID = @sanPhamid

			
			if @tmp < @orderqty
			begin
				update [Production].[ProductInventory]
				set Quantity = 0
				where Quantity = @tmp and ProductID = @sanPhamid

				set @orderqty = @orderqty - @tmp
			end
			else
			begin
				update [Production].[ProductInventory]
				set Quantity = Quantity - @orderqty
				where Quantity = @tmp and ProductID = @sanPhamid
				set @orderqty = 0
			end
		end
	end

	else
	begin
		print 'Khong the chen them !!!'
	end
end

	select sum(Quantity)
	from [Production].[ProductInventory]
	where ProductID = 777
insert into Sales.SalesOrderDetail([SalesOrderID], [SalesOrderDetailID], [CarrierTrackingNumber], [OrderQty], [ProductID], [SpecialOfferID], [UnitPrice], [UnitPriceDiscount])
values(                                 43659,            121318,                'asda',             148,          777,            1,            120,      0.1)
set IDENTITY_INSERT Sales.SalesOrderDetail on

select * from [Production].[ProductInventory] where ProductID = 777

select ProductID , max(Quantity) as 'So luong lon nhat'
from [Production].[ProductInventory]
group by ProductID, LocationID

select ProductID, Quantity
from [Production].[ProductInventory] 

select *
from sales.SpecialOfferProduct
select *
from Sales.SalesOrderDetail

	select sum(Quantity), bi.ProductID, sum(sod.OrderQty)
	from Sales.SalesOrderDetail sod join [Production].[Product] p on p.ProductID = sod.ProductID
	join [Production].[ProductInventory] bi on bi.ProductID = p.ProductID
	where bi.ProductID = 777
	group by bi.ProductID,sod.OrderQty


	select Quantity, bi.ProductID, sod.OrderQty
	from Sales.SalesOrderDetail sod join [Production].[Product] p on p.ProductID = sod.ProductID
	join [Production].[ProductInventory] bi on bi.ProductID = p.ProductID
	where bi.ProductID = 777

	select * from  Purchasing.ProductVendor


	select sum( MaxOrderQty) from Purchasing.ProductVendor where ProductID = 2 group by ProductID

	select * from [Production].[ProductInventory] where ProductID = 777


update 
				set Quantity = 0

-- cau 6
create table M_SalesPerson 
(
SalePSID int not null primary key, 
TerritoryID int,
BonusPS money
)
create table M_SalesOrderHeader 
(
SalesOrdID int not null primary key, 
OrderDate date,
SubTotalOrd money,
SalePSID int foreign key references M_SalesPerson(SalePSID)
)

insert into M_SalesPerson (SalePSID , TerritoryID, BonusPS )
select [BusinessEntityID], [TerritoryID], [Bonus]
from  [Sales].[SalesPerson]

insert into M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
select [SalesOrderID], [OrderDate], [SubTotal], [SalesPersonID]
from [Sales].[SalesOrderHeader]

create view huyhuhu
as
	select ms.SalePSID, TerritoryID, BonusPS, SalesOrdID, OrderDate, SubTotalOrd
	from M_SalesPerson ms join M_SalesOrderHeader mo on ms.SalePSID = mo.SalePSID

create trigger check_salesperson
on M_SalesOrderHeader
instead of insert
as
begin
	-- kiem tra 
	declare @tongSoTien money, @maNhanVien int
	select @maNhanVien = i.SalePSID 
	from inserted i

	--select @tongSoTien = sum(SubTotalOrd)
	--from M_SalesOrderHeader
	--where [SalesPersonID] = @maNhanVien
	if exists (select 1 from M_SalesPerson where M_SalesPerson.SalePSID = @maNhanVien)
	begin
		insert into M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
		select SalesOrdID, OrderDate, SubTotalOrd, SalePSID
		from inserted i

		select @tongSoTien = sum(SubTotalOrd)
		from M_SalesOrderHeader
		where SalePSID = @maNhanVien

		print @tongSoTien

		if @tongSoTien > 10000000
		begin
			update M_SalesPerson
			set BonusPS = BonusPS + 0.1*BonusPS
			where SalePSID = @maNhanVien
		end

	end
	else
	begin
		print 'Khong co ma nhan vien tren !!!'
	end
end
select sum(SubTotalOrd)
from M_SalesOrderHeader
where SalePSID = 290

-- 279 - 6700
select * from [dbo].[huyhuhu] where SalePSID = 279
select * from M_SalesPerson where SalesOrdID = 50000

insert into M_SalesOrderHeader (SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
values(5000012, getdate(), 10000000 , 290)

