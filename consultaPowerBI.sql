SELECT 
    p.categoryName        AS categoria,
    m.countryName         AS pais,
    m.brandName           AS marca,
    d.monthName           AS mes,
    d.year                AS anio,
    s.costTypeName        AS tipo_costo,

    SUM(s.totalCostUsd)       AS costo_usd,
    SUM(s.totalRevenueUsd)    AS venta_usd,
    SUM(s.totalProfitUsd)     AS rentabilidad_usd

FROM summaries s
JOIN products p ON s.productid = p.productid
JOIN markets m  ON s.marketid  = m.marketid
JOIN dates d    ON s.dateid    = d.dateid

GROUP BY 
    p.categoryName,
    m.countryName,
    m.brandName,
    d.monthName,
    d.year,
    s.costTypeName

ORDER BY 
    d.year,
    d.month,
    p.categoryName;