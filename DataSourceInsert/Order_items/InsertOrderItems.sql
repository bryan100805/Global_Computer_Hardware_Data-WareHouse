Use CompAccInc_OLTPTeamBryan;

Declare @OrderItems varchar(max)

Select @OrderItems =
BulkColumn
from OPENROWSET(BULK 'C:\Users\ryany\OneDrive\Desktop\SP Y2S1\DENG\CA2\DataSourceInsert\Order_Items\Order_items.json', SINGLE_BLOB) JSON

Insert into Order_Items
Select * From OpenJSON(@OrderItems, '$')
with (
Order_ID INT '$.order_id',
Item_ID INT '$.item_id',
Product_ID INT '$.product_id',
Quantity INT '$.quantity',
Unit_Price INT '$.unit_price')
