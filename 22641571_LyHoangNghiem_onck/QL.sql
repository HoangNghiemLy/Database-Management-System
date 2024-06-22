--c. xem lai ket qua cua NV1 va NV2
use AdventureWorks2008R2 
--NV1:
select * from [Purchasing].[PurchaseOrderDetail]
where PurchaseOrderDetailID = 571
--NV2:
select * from [Purchasing].[PurchaseOrderDetail]
where PurchaseOrderDetailID = 226 
--d. QL co the xem bang Purchasing.Vendor. Vi QL thuoc role db_datareader
select * from Purchasing.Vendor 