--c. 
use AdventureWorks2008R2
update [Purchasing].[PurchaseOrderDetail]
set ModifiedDate = GETDATE()
where PurchaseOrderDetailID = 571 
--test
select * from [Purchasing].[PurchaseOrderDetail]
where PurchaseOrderDetailID = 571
--d. NV1 khong the xem bang Purchasing.Vendor. Vi NV1 chi co quyen han tren bang Purchasing.PurchaseOrderDetail
select * from Purchasing.Vendor 