DO $$
DECLARE
	v_supplier_id int;
	v_status_id int;
	v_usd_id int;
	v_exchange_rate_id int;
	v_warehouse_id int;
	v_location_id int;
	v_admin_id int;
BEGIN
	SELECT s.supplierId INTO v_supplier_id
	FROM suppliers s
	ORDER BY s.supplierId DESC
	LIMIT 1;

	SELECT st.statusId INTO v_status_id
	FROM statuses st
	WHERE st.name = 'Received'
	ORDER BY st.statusId DESC
	LIMIT 1;

	SELECT c.currencyId INTO v_usd_id
	FROM currencies c
	WHERE c.isoCode = 'USD'
	ORDER BY c.currencyId DESC
	LIMIT 1;

	SELECT er.exchangeRateId INTO v_exchange_rate_id
	FROM exchangeRates er
	ORDER BY er.exchangeRateId DESC
	LIMIT 1;

	SELECT w.warehouseId INTO v_warehouse_id
	FROM warehouses w
	ORDER BY w.warehouseId DESC
	LIMIT 1;

	SELECT wl.locationId INTO v_location_id
	FROM warehouseLocations wl
	ORDER BY wl.locationId DESC
	LIMIT 1;

	SELECT e.employeeId INTO v_admin_id
	FROM employees e
	ORDER BY e.employeeId
	LIMIT 1;

	CALL spRegisterImportJson(
		v_supplier_id,
		v_status_id,
		(
		'[
			{"productVariantId":43,"quantity":60,"currencyId":'||v_usd_id||',"exchangeRateId":'||v_exchange_rate_id||',"unitCostLocal":6.50,"unitCostUsd":6.50,"warehouseId":'||v_warehouse_id||',"locationId":'||v_location_id||'},
			{"productVariantId":44,"quantity":50,"currencyId":'||v_usd_id||',"exchangeRateId":'||v_exchange_rate_id||',"unitCostLocal":7.80,"unitCostUsd":7.80,"warehouseId":'||v_warehouse_id||',"locationId":'||v_location_id||'},
			{"productVariantId":45,"quantity":40,"currencyId":'||v_usd_id||',"exchangeRateId":'||v_exchange_rate_id||',"unitCostLocal":8.20,"unitCostUsd":8.20,"warehouseId":'||v_warehouse_id||',"locationId":'||v_location_id||'},
			{"productVariantId":46,"quantity":30,"currencyId":'||v_usd_id||',"exchangeRateId":'||v_exchange_rate_id||',"unitCostLocal":9.10,"unitCostUsd":9.10,"warehouseId":'||v_warehouse_id||',"locationId":'||v_location_id||'},
			{"productVariantId":47,"quantity":20,"currencyId":'||v_usd_id||',"exchangeRateId":'||v_exchange_rate_id||',"unitCostLocal":10.00,"unitCostUsd":10.00,"warehouseId":'||v_warehouse_id||',"locationId":'||v_location_id||'}
		]'
		)::json,
		v_admin_id
	);
END;
$$;

-- verificar
SELECT ii.productVariantId, ii.unitCostUsd
FROM importItems ii
WHERE ii.productVariantId BETWEEN 43 AND 47
ORDER BY ii.productVariantId;