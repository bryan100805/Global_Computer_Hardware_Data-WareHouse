USE CompAccInc_OLTPTeamBryan;

BULK INSERT Product_Categories
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Desktop\SP Y2S1\DENG\CA2\DataSourceInsert\Product_Categories\Product_Categories.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = ',,,\n'
)