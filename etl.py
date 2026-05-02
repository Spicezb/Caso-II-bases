import pandas as pd
from sqlalchemy import create_engine, text

# Conecciones Xavi
mysql_engine = create_engine(
    "mysql+pymysql://root:123456@localhost:3306/dynamic"
)
etheria_engine = create_engine(
    "postgresql://postgres:123456@localhost:5434/etheria"
)
dw_engine = create_engine(
    "postgresql://postgres:123456@localhost:5435/datawarehouse"
)

# conecciones Sebas
# mysql_engine = create_engine(
#     "mysql+pymysql://dynamic_user:dynamic123@localhost:3307/DynamicBrandsRetail"
# )
# etheria_engine = create_engine(
#     "postgresql://postgres:1407@localhost:5432/EtheriaGlobal"
# )
# dw_engine = create_engine(
#     "postgresql://postgres:1234@localhost:5435/etheria_dw"
# )

with dw_engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE summaries RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE products RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE markets RESTART IDENTITY CASCADE;"))
    conn.execute(text("TRUNCATE TABLE dates RESTART IDENTITY CASCADE;"))

sales_query = """
SELECT 
    pc.name AS categoryName,
    b.name AS brandName,
    c.name AS countryName,
    o.orderDate,
    od.quantity,
    od.lineSubtotal,
    cp.productVariantId,
    cur.isoCode AS currencyCode,
    er.rate AS rateToUsd
FROM orderDetails od
JOIN orders o ON od.orderId = o.orderId
JOIN commercialProducts cp ON od.commercialProductId = cp.commercialProductId
JOIN baseProducts bp ON cp.baseProductId = bp.baseProductId
JOIN productCategories pc ON bp.productCategoryId = pc.productCategoryId
JOIN brands b ON cp.brandId = b.brandId
JOIN websites w ON o.websiteId = w.websiteId
JOIN countries c ON w.countryId = c.countryId
JOIN currencies cur ON o.currencyId = cur.currencyId
JOIN exchangeRates er ON o.exchangeRateId = er.exchangeRateId
"""

df_sales = pd.read_sql(sales_query, mysql_engine)
df_sales.columns = df_sales.columns.str.lower()

cost_query = """
SELECT 
    ii.productVariantId,
    ii.unitCostUsd
FROM importItems ii
"""

df_costs = pd.read_sql(cost_query, etheria_engine)
df_costs.columns = df_costs.columns.str.lower()

df = df_sales.merge(df_costs, on="productvariantid", how="inner")

if df.empty:
    raise ValueError("No hay coincidencias entre ventas y costos.")

df["orderdate"] = pd.to_datetime(df["orderdate"])
df["month"] = df["orderdate"].dt.month
df["year"] = df["orderdate"].dt.year
df["monthname"] = df["orderdate"].dt.strftime("%B")

# ingresos
df["revenue_original"] = df["linesubtotal"]
df["revenueusd"] = df["revenue_original"] * df["ratetousd"]

# costo único
df["costusd"] = df["unitcostusd"] * df["quantity"]
df["profitusd"] = df["revenueusd"] - df["costusd"]
df["costtypename"] = "import"

df_summary = df.groupby([
    "categoryname",
    "brandname",
    "countryname",
    "month",
    "monthname",
    "year",
    "costtypename",
    "currencycode",
    "ratetousd"
]).agg({
    "costusd": "sum",
    "revenueusd": "sum",
    "profitusd": "sum"
}).reset_index()

df_products = df_summary[["categoryname"]].drop_duplicates()
df_products.to_sql("products", dw_engine, if_exists="append", index=False)

df_markets = df_summary[["countryname", "brandname"]].drop_duplicates()
df_markets.to_sql("markets", dw_engine, if_exists="append", index=False)

df_dates = df_summary[["month", "monthname", "year"]].drop_duplicates()
df_dates.to_sql("dates", dw_engine, if_exists="append", index=False)

products_db = pd.read_sql("SELECT * FROM products", dw_engine)
markets_db = pd.read_sql("SELECT * FROM markets", dw_engine)
dates_db = pd.read_sql("SELECT * FROM dates", dw_engine)

products_db.columns = products_db.columns.str.lower()
markets_db.columns = markets_db.columns.str.lower()
dates_db.columns = dates_db.columns.str.lower()

df_final = df_summary.merge(products_db, on="categoryname")
df_final = df_final.merge(markets_db, on=["countryname", "brandname"])
df_final = df_final.merge(dates_db, on=["month", "monthname", "year"])

df_insert = df_final[[
    "productid",
    "marketid",
    "dateid",
    "costtypename",
    "currencycode",
    "ratetousd",
    "costusd",
    "revenueusd",
    "profitusd"
]].rename(columns={
    "ratetousd": "exchangeratetousd",
    "costusd": "totalcostusd",
    "revenueusd": "totalrevenueusd",
    "profitusd": "totalprofitusd"
})

df_insert.to_sql("summaries", dw_engine, if_exists="append", index=False)

print("ETL FINAL FUNCIONANDO 💣")