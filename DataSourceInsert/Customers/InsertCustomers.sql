USE CompAccInc_OLTPTeamBryan;

BULK INSERT Customers
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Desktop\SP Y2S1\DENG\CA2\DataSourceInsert\Customers\Customers.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 1,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)