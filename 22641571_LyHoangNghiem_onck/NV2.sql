--c. Xoa don hang co ma don hang la 226
use AdventureWorks2008R2
select * from [Purchasing].[PurchaseOrderDetail]
where PurchaseOrderDetailID = 226 
--xoa
delete Purchasing.PurchaseOrderDetail
where PurchaseOrderDetailID = 226
--d. NV2 khong the xem bang Purchasing.Vendor. Vi NV2 chi co quyen han tren bang Purchasing.PurchaseOrderDetail
select * from Purchasing.Vendor 