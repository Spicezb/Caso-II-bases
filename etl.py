import pandas as pd
from sqlalchemy import create_engine, text

mysql_engine = create_engine("mysql+pymysql://root:1234@localhost:3306/dynamic")
etheria_engine = create_engine("postgresql://postgres:1234@localhost:5434/etheria")
dw_engine = create_engine("postgresql://postgres:1234@localhost:5435/etheria_dw")

with dw_engine.connect() as conn:
    conn.execute(text("TRUNCATE TABLE summaries RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE products RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE markets RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE dates RESTART IDENTITY CASCADE;"))

sales_query = """
SELECT 
    bp.categoryName,
    b.name AS brandName,
    w.countryId,
    o.orderDate,
    od.quantity,
    od.lineSubtotal,
    cp.productVariantId
FROM orderDetails od
JOIN orders o ON od.orderId = o.orderId
JOIN commercialProducts cp ON od.commercialProductId = cp.commercialProductId
JOIN baseProducts bp ON cp.baseProductId = bp.baseProductId
JOIN brands b ON cp.brandId = b.brandId
JOIN websites w ON o.websiteId = w.websiteId
"""

df_sales = pd.read_sql(sales_query, mysql_engine)

cost_query = """
SELECT 
    ii.productVariantId,
    ii.unitCostUsd
FROM importItems ii
"""

df_costs = pd.read_sql(cost_query, etheria_engine)

df = df_sales.merge(df_costs, on="productVariantId", how="inner")

df["orderDate"] = pd.to_datetime(df["orderDate"])
df["month"] = df["orderDate"].dt.month
df["year"] = df["orderDate"].dt.year
df["monthName"] = df["orderDate"].dt.strftime("%B")

df["revenueUsd"] = df["lineSubtotal"]
df["costUsd"] = df["unitCostUsd"] * df["quantity"]
df["profitUsd"] = df["revenueUsd"] - df["costUsd"]

df["costTypeName"] = "import"

df_summary = df.groupby([
    "categoryName",
    "brandName",
    "countryId",
    "month",
    "monthName",
    "year",
    "costTypeName"
]).agg({
    "costUsd": "sum",
    "revenueUsd": "sum",
    "profitUsd": "sum"
}).reset_index()

# PRODUCTS
df_products = df_summary[["categoryName"]].drop_duplicates()
df_products.to_sql("products", dw_engine, if_exists="append", index=False)

# MARKETS
df_markets = df_summary[["countryId", "brandName"]].drop_duplicates()
df_markets.rename(columns={"countryId": "countryName"}, inplace=True)
df_markets.to_sql("markets", dw_engine, if_exists="append", index=False)

# DATES
df_dates = df_summary[["month", "monthName", "year"]].drop_duplicates()
df_dates.to_sql("dates", dw_engine, if_exists="append", index=False)

products_db = pd.read_sql("SELECT * FROM products", dw_engine)
markets_db = pd.read_sql("SELECT * FROM markets", dw_engine)
dates_db = pd.read_sql("SELECT * FROM dates", dw_engine)

df_final = df_summary.merge(products_db, on="categoryName")
df_final = df_final.merge(markets_db, on="brandName")
df_final = df_final.merge(dates_db, on=["month", "monthName", "year"])

df_insert = df_final[[
    "productid",
    "marketid",
    "dateid",
    "costTypeName",
    "costUsd",
    "revenueUsd",
    "profitUsd"
]].rename(columns={
    "costUsd": "totalCostUsd",
    "revenueUsd": "totalRevenueUsd",
    "profitUsd": "totalProfitUsd"
})

df_insert.to_sql("summaries", dw_engine, if_exists="append", index=False)

print("ETL COMPLETO Y CORRECTO 💣")