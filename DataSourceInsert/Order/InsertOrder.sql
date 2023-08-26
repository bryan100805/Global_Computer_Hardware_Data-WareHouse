Use CompAccInc_OLTPTeamBryan;

Declare @Order varchar(max)

Select @Order =
BulkColumn
from OPENROWSET(BULK 'C:\Users\ryany\OneDrive\Desktop\SP Y2S1\DENG\CA2\DataSourceInsert\Order\Order.json', SINGLE_BLOB) JSON

Insert into Orders
Select * From OpenJSON(@Order, '$')
with (
Order_ID INT '$.order_id',
Customer_ID INT '$.customer_id',
Status VARCHAR(30) '$.status',
Salesman_ID INT '$.salesman_id',
Order_Date DATE '$.order_date')
