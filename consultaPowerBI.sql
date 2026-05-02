SELECT 
    p.categoryname      AS categoria,
    m.countryname       AS pais,
    m.brandname         AS marca,
    d.monthname         AS mes,
    d.year              AS anio,
    s.costtypename      AS tipo_costo,
    s.currencycode      AS moneda,

    SUM(s.totalcostusd)        AS costo_usd,
    SUM(s.totalrevenueusd)     AS venta_usd,
    SUM(s.totalprofitusd)      AS rentabilidad_usd,

    -- margen %
    CASE 
        WHEN SUM(s.totalrevenueusd) = 0 THEN 0
        ELSE (SUM(s.totalprofitusd) / SUM(s.totalrevenueusd)) * 100
    END AS margen_porcentaje

FROM summaries s
JOIN products p ON s.productid = p.productid
JOIN markets m  ON s.marketid  = m.marketid
JOIN dates d    ON s.dateid    = d.dateid

GROUP BY 
    p.categoryname,
    m.countryname,
    m.brandname,
    d.month,
    d.monthname,
    d.year,
    s.costtypename,
    s.currencycode

ORDER BY 
    d.year,
    d.month,
    p.categoryname