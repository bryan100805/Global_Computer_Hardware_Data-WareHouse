USE CompAccInc_OLTPTeamBryan;

--Products
SELECT * FROM Products FOR JSON PATH, INCLUDE_NULL_VALUES;

--ProductStock
SELECT p.Product_ID, p.Product_Name, w.Warehouse_ID, w.Warehouse_Name, l.Location_ID, l.Address, c.Country_Name, r.Region_Name, i.Quantity
FROM Inventories i, Products p, Warehouses w, Locations l, Countries c, Regions r
WHERE 
p.Product_ID = i.Product_ID AND w.Warehouse_ID = i.Warehouse_ID AND l.Location_ID = w.Location_ID 
AND l.Country_ID = c.Country_ID AND r.Region_ID = c.Region_ID
FOR JSON PATH, INCLUDE_NULL_VALUES;

--ProductSold
SELECT p.Product_ID, SUM(ISNULL(oi.Quantity,0)) as total_qty_sold
FROM Products p
LEFT JOIN Order_Items oi
ON p.Product_ID = oi.Product_ID
GROUP BY p.Product_ID
FOR JSON PATH, INCLUDE_NULL_VALUES;