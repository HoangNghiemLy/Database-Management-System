--tao login
use master
create login TN WITH PASSWORD = 'garen123'
create login QL with password = 'garen123'
create login NV with password = 'garen123'

use AdventureWorks2008R2
create user TN for login TN
create user QL for login QL
create user NV for login NV

--phan quyen  (admin chi cap quyen cho TN, ql thoi)
grant insert, delete, update, select on [HumanResources].[EmployeeDepartmentHistory] to TN with grant option -- with grant option de cho user tn co the gan quyen cho user nv
exec sp_addrolemember 'db_datareader', 'QL'

--c.??ng nh?p ph� h?p, m? c?a s?  query t??ng ?ng v� vi?t l?nh ??: Nh�n vi�n TN s?a 1 d�ng d? li?u t�y �, nh�n vi�n NV x�a 1 d�ng d? li?u t�y � v� nh�n vi�n QL xem l?i k?t qu? th?c hi?n c?a 2 NV tr�n. (L?u �: 
--L?u t�n c�c c?a s? query l�m vi?c
--?ng v?i c�c nh�n vi�n l� tenSV_TN, tensv_NV, tensv_QL v� l?u c�c query n�y v�o th? m?c b�i l�m) (1?)


--d.Nh�n vi�n NV ngh? vi?c, tr??ng nh�m h�y thu h?i quy?n c?p cho NV n�y. Vi?t l?nh ki?m tra quy?n tr�n c?a s? query c?a NV (1?). 

--e.Nh�m nh�n vi�n ho�n th�nh d? �n,
--admin h�y v� hi?u h�a c�c ho?t ??ng c?a nh�m n�y tr�n CSDL. 
--Vi?t l?nh ki?m tra quy?n tr�n c?a s? query c?a c�c nh�n vi�n (1?).

--PH?N 2
--C�u 3: (10 ?)
--H�y l�n k? ho?ch ph?c h?i c? s? d? li?u cho c�c ho?t ??ng sau b?ng c�ch vi?t c�c l?nh Backup t?i c�c v? tr� [...] ?? th?c hi?n Restore c? s? d? li?u theo y�u c?u ? c�u e.
--a.[Vi?t l?nh th?c hi?n Full Backup?]. (2?)
--buoc 1 tao khu vuc luu tru cho database
EXEC sp_addumpdevice 'disk', 'adv2008back', 'D:\backup\adv2008back.bak'
exec sp_dropdevice 'adv2008back'
--buoc 2 set database recovery full mode hoac recovery simple
use master
alter database AdventureWorks2008R2 set recovery full
--buoc 3 tao full backup

BACKUP DATABASE AdventureWorks2008R2
TO DISK = 'D:\backup\adv2008back.bak'
WITH DESCRIPTION = ' FULL Backup' -- file 1

backup log AdventureWorks2008R2
to disk = 'D:\backup\adv2008back.bak'
with description = 'adv2008back.bak Log Backup' -- file 2



--b.T?o m?t transaction t?ng l??ng (Rate) th�m 10% cho c�c nh�n vi�nl�m vi?c ca (Shift.Name)  chi?u v� t?ng 20% l??ng cho c�c nh�n vi�n l�m vi?c ca ?�m. [Differential Backup]. (2?)

select * from  [HumanResources].[EmployeePayHistory]

begin tran
	update [HumanResources].[EmployeePayHistory]
	set Rate =Rate +  Rate * 0.1
	from [HumanResources].[EmployeePayHistory] eph join [HumanResources].[EmployeeDepartmentHistory] edh
	on eph.[BusinessEntityID] = edh.[BusinessEntityID] join [HumanResources].[Shift] s
	 on s.[ShiftID] = edh.[ShiftID]
	where s.Name like 'Evening'
commit tran
end tran

backup database AdventureWorks2008R2 -- file 3
to adv2008back
with differential;



--c.Xo?a mo?i ba?n ghi trong ba?ng ProductCostHistory. [Ghi nh?n d? li?u ?ang c� v� Vi?t l?nh Differential Backup] (2?).

delete from [Production].[ProductCostHistory]

backup database AdventureWorks2008R2 -- file 4
to adv2008back
with differential;

--d.B�? sung th�m 1 s�? phone m??i (Person.PersonPhone) cho nh�n vi�n co? ma? s�? nh�n vi�n (BusinessEntityID) la? 10001. [Log Backup] (2?).

select * from Person.PersonPhone
where BusinessEntityID = 10001

insert into Person.PersonPhone ([BusinessEntityID],[PhoneNumber],[PhoneNumberTypeID],[ModifiedDate] )
values(10001, '082-322-4444', 2, getdate())

backup log AdventureWorks2008R2 --file 5
to adv2008back

--Processed 17 pages for database 'AdventureWorks2008R2', file 'AdventureWorks2008R2_Log' on file 5.
--BACKUP LOG successfully processed 17 pages in 0.004 seconds (32.836 MB/sec).

--Completion time: 2024-05-18T18:45:54.2268754+07:00


--e.X�a CSDL AdventureWorks2008R2. Ph?c h?i CSDL v? tr?ng th�i b??c c. Ki?m tra xem d? li?u ph?c h?i c� ??t y�u c?u kh�ng (l??ng c� t?ng, c�c b?n ghi c� b? x�a, ch?a c� th�m s? phone m?i)? (2?)

use master
drop database AdventureWorks2008R2

restore headeronly
from disk = 'D:\backup\adv2008back.bak'



restore database AdventureWorks2008R2
from adv2008back
with file=1, norecovery;


restore database AdventureWorks2008R2
from adv2008back
with file =2, norecovery;

restore database AdventureWorks2008R2 -- file 4
from adv2008back
with file = 3, norecovery

restore database AdventureWorks2008R2 -- file 4
from adv2008back
with file = 4, recovery


select *
from [Production].[ProductCostHistory]

select * from Person.PersonPhone
where BusinessEntityID = 10001
