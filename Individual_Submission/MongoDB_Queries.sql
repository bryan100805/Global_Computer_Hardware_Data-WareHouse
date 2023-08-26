--Query 1
 db.ProductSold.find({total_qty_sold:{$eq: 0}})

 db.ProductSold.distinct("Product_ID", {total_qty_sold:0})

--Query 2
db.ProductSold.aggregate([
        {$lookup: { from: "ProductStock", localField: "Product_ID", foreignField: "Product_ID", as:"ProductStock"}},
        {$unwind:{path: "$ProductStock",preserveNullAndEmptyArrays: true}},
        {$group: {_id: "$Product_ID",
                Product_ID: {$first: "$Product_ID"}, 
                total_qty_sold: {$sum: "$total_qty_sold"}, 
                totalStock: { $sum: "$ProductStock.Quantity" }
                }},
        {$match:{total_qty_sold:0}},
        {$sort:{totalStock:-1}},
        {$project:{_id:0, Product_ID:'$Product_ID', total_qty_sold: '$total_qty_sold', totalStock: '$totalStock'}}
])

db.ProductSold.aggregate([{$lookup: { from: "ProductStock", localField: "Product_ID", foreignField: "Product_ID", as:"ProductStock"}},{$unwind:{path: "$ProductStock",preserveNullAndEmptyArrays: true}},{$group: {_id: "$Product_ID", Product_ID: {$first: "$Product_ID"}, total_qty_sold: {$sum: "$Total Qty Sold"}, totalStock: { $sum: "$ProductStock.Quantity" }}},
{$match:{total_qty_sold:0}},{$sort:{totalStock:-1}},{$project:{_id:0, Product_ID:'$Product_ID', total_qty_sold: '$total_qty_sold', totalStock: '$totalStock'}}])


--Query 3
db.ProductStock.aggregate([ 
        {$group: { _id: {country_name: "$Country_Name", warehouse_name: "$Warehouse_Name"}}},
        {$project: {_id:0, countryWarehouse: {$concat:["$_id.country_name", " - ", "$_id.warehouse_name"]}}}
])

-- Final Answer
db.ProductStock.aggregate([ 
        {$group: { _id: {country_name: "$Country_Name", warehouse_name: "$Warehouse_Name"}}}
])

-- Attempted
db.ProductStock.aggregate([
        {$group: {_id: {$concat: ["$Country_Name", " - ", "$Warehouse_Name"]},
                count: {$sum:1}}},
        {$match:{count:1}},
        {$group:{_id:null, unduplicatedCountryWareHouse:{$addToSet:"$_id"}}},
        {$project: {_id: 0, unduplicatedCountryWareHouse:1}}
]);

--Query 4

--Check for every Warehouse_Name
db.ProductStock.aggregate([
        {$group: {_id: "$Warehouse_Name",total_Products:{$addToSet:"$Product_Name"}}},
        {$project: {_id: 0, Warehouse_Name: "$_id", NumberofProducts:{$size: "$total_Products"}}}
]);

--Check for every Warehouse_ID and print Warehouse_Name in the output
db.ProductStock.aggregate([{$group: {_id: "$Warehouse_ID", Warehouse_Name:{$first:"$Warehouse_Name"},total_Products:{$addToSet:"$Product_Name"}}},
{$project: {_id: 0, Warehouse_Name: 1, NumberofProducts:{$size: "$total_Products"}}}]);

db.ProductStock.aggregate([{$group: {_id: "$Warehouse_ID", Warehouse_Name:{$first:"$Warehouse_Name"},total_Products:{$addToSet:"$Product_ID"}}},
{$project: {_id: 0, Warehouse_Name: 1, NumberofProducts:{$size: "$total_Products"}}}]);
