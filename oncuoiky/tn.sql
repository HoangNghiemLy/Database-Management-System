select *
from [HumanResources].[EmployeeDepartmentHistory]

-- chinh sua du lieu
update [HumanResources].[EmployeeDepartmentHistory]
set StartDate = getdate()
where BusinessEntityID = 3 and DepartmentID = 1

-- cap quyen cho nhan vien
grant insert, delete, update, select on [HumanResources].[EmployeeDepartmentHistory] to NV

-- d.Nh�n vi�n NV ngh? vi?c, tr??ng nh�m h�y thu h?i quy?n c?p cho NV n�y. Vi?t l?nh ki?m tra quy?n tr�n c?a s? query c?a NV (1?). 
revoke insert, delete, update, select on [HumanResources].[EmployeeDepartmentHistory] to NV