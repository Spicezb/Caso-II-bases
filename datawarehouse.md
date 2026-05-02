# tables

## products
- productid SERIAL PK
- categoryName VARCHAR(100)

## markets
- marketid SERIAL PK
- countryName VARCHAR(100)
- brandName VARCHAR(100)

## dates
- dateid SERIAL PK
- month INT
- monthName VARCHAR(20)
- year INT

## summaries
- summaryid SERIAL PK
- productid INT FK NOT NULL
- marketid INT FK NOT NULL
- dateid INT FK NOT NULL
- currencycode VARCHAR(10),
- exchangeratetousd NUMERIC(10,4),
- costTypeName VARCHAR(50)
- totalCostUsd NUMERIC(12,2)
- totalRevenueUsd NUMERIC(12,2)
- totalProfitUsd NUMERIC(12,2)