

-- kiem tra dulieu thay doi tu TN
select *
from [HumanResources].[EmployeeDepartmentHistory]
where BusinessEntityID = 3 and DepartmentID = 1
-- kiem tra du lieu xoa di tu NV
select *
from [HumanResources].[EmployeeDepartmentHistory]
where BusinessEntityID = 6 and DepartmentID = 1